import RxSwift
import RxCocoa

protocol SeeConversationDisplayLogic : class {
    func goBack()
    func clearText()
    func goPickMedia()
    func onNewData(items: [MessageItem])
    func onNewSingleData(item: MessageItem)
    
    func notifyItems()
    func notifyItem(with addRespond: (Bool, Int))
}

class SeeConversationViewModel : ViewModelDelegate {
    private weak var displayLogic: SeeConversationDisplayLogic?
    private let disposeBag: DisposeBag
    
    let contactItem: ContactItem?
    let conversationItem: ConversationItem?
    
    let textMessageContent = BehaviorRelay<String>(value: "")
    
    private let dataSource: MessasgeItemDataSource = MessasgeItemDataSource()
    
    private let loadConvoFromContactIdUseCase = LoadConvoFromContactIdUseCase()
    private let loadConvoFromConvoIdUseCase = LoadConvoFromConvoIdUseCase()
    private let sendMessageUseCase = SendMessageUseCase()
    private let sendMessageToUserUseCase = SendMessageToUserUseCase()
    private let getConversationLabelUseCase = GetConversationLabelUseCase()
    private let getUserUseCase = GetUserUseCase()
    private let getContactNicknameUseCase = GetContactNicknameUseCase()
    private let observeNextMessageUseCase = ObserveNextMessageUseCase()
    
    /* We falsely use timestamp of last message
     * and offset it by 1 to create timestamp
     * of new message on local storage
     * because we don't need time accuracy
     * we just need to preserve order
     */
    private var lastMessTime: Int64 = 0
    
    init(displayLogic: SeeConversationDisplayLogic, contactItem: ContactItem) {
        self.displayLogic = displayLogic
        self.contactItem = contactItem
        self.disposeBag = DisposeBag()
        self.conversationItem = nil
    }
    
    init(displayLogic: SeeConversationDisplayLogic, conversationItem: ConversationItem) {
        self.displayLogic = displayLogic
        self.conversationItem = conversationItem
        self.disposeBag = DisposeBag()
        self.contactItem = nil
    }

    // init(displayLogic: SeeConversationDisplayLogic, chatHistoryItem: ChatHistoryItem) { }
    
    func transform(input: Input) -> Output {
        
        (input.textMessage <-> self.textMessageContent)
            .disposed(by: self.disposeBag)
        
        
        if contactItem != nil {
            return transformWithContactItem(
                input: input, contactItem: contactItem!)
        }
        
        if conversationItem != nil {
            return transfromWithConversationItem(
                input: input, conversationItem: conversationItem!)
        }
        
        fatalError("ContactItem or ConversationItem must be not nil, or it is impossible to load conversation")
    }
    
    // TODO: Move all displayLogic interaction into drive() block.
    func transformWithContactItem(input: Input, contactItem: ContactItem) -> Output {
        let errorTracker = ErrorTracker()
        
        input.trigger
            .flatMap { [unowned self] (_) -> Driver<[Message]> in
                let request = LoadConvoFromContactRequest(contact: contactItem.contact)
                
                return self.getUserUseCase
                    .execute(request: ())
                    .flatMap { [unowned self] (user) -> Observable<[Message]> in
                        return self.loadConvoFromContactIdUseCase
                            .execute(request: request)
                            .do(onNext: { [unowned self] (messages) in
                                let messageItems = self.convert(messages: messages, user: user)
                                self.displayLogic?.onNewData(items: messageItems)
                                self.observeNextMessage(fromLastId: messageItems.first?.message.getMessageId(),
                                                        withTracker: errorTracker)
                            })
                    }
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)

        input.sendMessTrigger
            .flatMap { [unowned self] (_) -> Driver<Bool> in
                return self.getUserUseCase.execute(request: ())
                    .flatMap { [unowned self] (user) -> Observable<Bool> in
                        guard !self.textMessageContent.value
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .isEmpty else {
                                return Observable.just(false)
                        }
                        
                        let message = self.parseTextMessage(user)
                        
                        self.displayLogic?.clearText()
                        self.textMessageContent.accept("")
                      
                        return self.sendMessageToUserUseCase
                            .execute(request: SendMessageToUserRequest(
                                message: message,
                                toUser: contactItem.contact))
                    }
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)
        
        
        self.getContactNicknameUseCase
            .execute(request: GetContactNickNameRequest(contact: contactItem.contact))
            .bind(to: input.conversationLabel)
            .disposed(by: self.disposeBag)
        
        input.sendImageTrigger
            .drive(onNext: { [unowned self] (_) in
                self.displayLogic?.goPickMedia()
            })
            .disposed(by: self.disposeBag)
        
        input.sendImagePublish
            .flatMap { [unowned self] (url) -> Driver<Bool> in
                return self.getUserUseCase.execute(request: ())
                    .flatMap { [unowned self] (user) -> Observable<Bool> in
                        
                        let message = self.parseImageMessage(user, url)
                        
                        let request = SendMessageToUserRequest(message: message, toUser: contactItem.contact)
                        return self.sendMessageToUserUseCase
                            .execute(request: request)
                            .do()
                    }
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)
        
        return Output (error: errorTracker.asDriver(), dataSource: self.dataSource)
    }
    
    func transfromWithConversationItem(input: Input, conversationItem: ConversationItem) -> Output {
        let errorTracker = ErrorTracker()
        input.trigger
            .flatMap { [unowned self] (_) -> Driver<[MessageItem]> in
                let request = LoadConvoFromConvoIdRequest(convoId: conversationItem.conversation.id)
                
                return self.getUserUseCase
                    .execute(request: ())
                    .flatMap { [unowned self] (user) -> Observable<[MessageItem]> in
                        
                        return self.loadConvoFromConvoIdUseCase
                            .execute(request: request)
                            .do()
                            .flatMap { [unowned self] (messages) -> Observable<[MessageItem]> in
                                let messageItems = self.convert(messages: messages, user: user)
                                self.observeNextMessage(fromLastId: messageItems.first?.message.getMessageId(),
                                                        withTracker: errorTracker)
                                return Observable.just(messageItems)
                        }
                    }
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive(onNext: { [unowned self] (items) in
                self.notifyItems(with: items)
            })
            .disposed(by: self.disposeBag)
        
        input.sendMessTrigger
            .flatMap { [unowned self] (_) -> Driver<Bool> in
                return self.getUserUseCase.execute(request: ())
                    .flatMap { [unowned self] (user) -> Observable<Bool> in
                        guard !self.textMessageContent.value
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .isEmpty else {
                            return Observable.just(false)
                        }
                        
                        let message = self.parseTextMessage(user)
                        self.displayLogic?.clearText()
                        self.textMessageContent.accept("")
                        
                        return self.sendMessageUseCase
                            .execute(request: SendMessageRequest(
                                message: message,
                                conversationId: conversationItem.conversation.id))
                    }
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
                
            }
            .drive()
            .disposed(by: self.disposeBag)

        let request = GetConversationLabelRequest(
            conversation: conversationItem.conversation)
        
        self.getConversationLabelUseCase
            .execute(request: request)
            .bind(to: input.conversationLabel)
            .disposed(by: self.disposeBag)
        
        input.sendImageTrigger
            .drive(onNext: { [unowned self] (_) in
                self.displayLogic?.goPickMedia()
            })
            .disposed(by: self.disposeBag)

        
        input.sendImagePublish
            .flatMap { [unowned self] (url) -> Driver<Bool> in
                return self.getUserUseCase.execute(request: ())
                    .flatMap { [unowned self] (user) -> Observable<Bool> in
                        
                        let message = self.parseImageMessage(user, url)
                        
                        return self.sendMessageUseCase
                            .execute(request: SendMessageRequest(
                                message: message,
                                conversationId: conversationItem.conversation.id))
                            .do()
                    }
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
        }
        .drive()
        .disposed(by: self.disposeBag)

        return Output(
            error: errorTracker.asDriver(), dataSource: self.dataSource)
    }
    
    private func notifyItems(with items: [MessageItem]) {
        lastMessTime = Int64(items.first?.message.getAtTime() ?? "\(lastMessTime)") ?? lastMessTime
        // self.displayLogic?.onNewData(items: items)
        self.dataSource.setItems(items: items)
        self.displayLogic?.notifyItems()
    }
    
    private func notifySingleItem(with item: MessageItem) {
        self.lastMessTime = Int64(item.message.getAtTime() ) ?? self.lastMessTime
        // self.displayLogic?.onNewSingleData(item: item)
        let addRespond = self.dataSource.addOrUpdateSingleItem(item: item)
        self.displayLogic?.notifyItem(with: addRespond)
    }
    
    private func observeNextMessage(fromLastId lastId: String?, withTracker errorTracker: ErrorTracker) {
        self.getUserUseCase
            .execute(request: ())
            .flatMap { [unowned self] (user) in
                return self.observeNextMessageUseCase
                    .execute(request: ObserveNextMessageRequest(fromLastId: lastId))
                    .map { (message) -> (Message, User) in
                        return (message, user)
                    }
                    .do(onNext: { [unowned self] (mess, user) in
                        let item = self.convert(messages: [mess], user: user).first
                        if item != nil {
                            self.notifySingleItem(with: item!)
                        }
                    })
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .asDriverOnErrorJustComplete()
            .drive()
            .disposed(by: self.disposeBag)
    }
    
    private func parseImageMessage(_ user: User, _ url: URL) -> Message {
        return Message(type: .image, convId: nil, content: url.path,
                       atTime: self.getTime(), sentBy: user.userId,
                       messId: url.lastPathComponent, isSending: true)
    }
    
    private func convert(localMessage: Message) -> MessageItem {
        switch localMessage.type {
        case .image:
            return MessageItem(messageItemType: .imageMe, message: localMessage)
        case .text:
            return MessageItem(messageItemType: .textMe, message: localMessage)
        }
    }
    
    private func convert(messages: [Message], user: User) -> [MessageItem] {
        var res: [MessageItem] = []
        for (index, m) in messages.enumerated() {
            let showTime = index == 0
                || !m.getSentBy().elementsEqual(messages[index - 1].getSentBy())
            
            switch m.type {
            case .image:
                if m.getSentBy().elementsEqual(user.userId) {
                    res.append(MessageItem(messageItemType: .imageMe, message: m, showTime: showTime))
                } else {
                    res.append(MessageItem(messageItemType: .image, message: m, showTime: showTime))
                }
                
            case .text:
                if m.getSentBy().elementsEqual(user.userId) {
                    res.append(MessageItem(messageItemType: .textMe, message: m, showTime: showTime))
                } else {
                    res.append(MessageItem(messageItemType: .text, message: m, showTime: showTime))
                }
            }
        }

        return res
    }
    
    private func parseTextMessage(_ user: User) -> Message {
        let localIdentifier = UUIDGenerator.newUUID()
        var data = [String : String]()
        data["mess-id"] = localIdentifier
        data["local-id"] = localIdentifier
        data["content"] =
            self.textMessageContent.value
                .trimmingCharacters(in: .whitespacesAndNewlines)
        data["type"] = "text"
        data["at-time"] = self.getTime()
        data["sent-by"] = user.userId
        return Message(type: .text, data: data, isSending: true)
    }
    
    private func getTime() -> String {
        return "\(lastMessTime + 1)"
    }
}

extension SeeConversationViewModel {
    struct Input {
        let trigger: Driver<Void>
        let sendMessTrigger: Driver<Void>
        let conversationLabel: Binder<String?>
        let textMessage: ControlProperty<String>
        let sendImageTrigger: Driver<Void>
        let sendImagePublish: Driver<URL>
    }
    
    struct Output {
        let error: Driver<Error>
        let dataSource: UITableViewDataSource
    }
    
    enum Item {
        case text(message: Message)
        case textMe(message: Message)
        case image(message: Message)
        case imageMe(message: Message)
    }
}
