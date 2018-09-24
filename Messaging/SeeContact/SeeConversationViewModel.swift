import RxSwift
import RxCocoa

protocol SeeConversationDisplayLogic : class {
    func goBack()
    func clearText()
    func goPickMedia()
    func onNewData(items: [MessageItem])
    func onNewSingleData(item: MessageItem)
}

class SeeConversationViewModel : ViewModelDelegate {
    private weak var displayLogic: SeeConversationDisplayLogic?
    private let disposeBag: DisposeBag
    
    let contactItem: ContactItem?
    let conversationItem: ConversationItem?
    
    let textMessageContent = BehaviorRelay<String>(value: "")
    
    private let loadConvoFromContactIdUseCase = LoadConvoFromContactIdUseCase()
    private let loadConvoFromConvoIdUseCase = LoadConvoFromConvoIdUseCase()
    private let sendMessageUseCase = SendMessageUseCase()
    private let sendMessageToUserUseCase = SendMessageToUserUseCase()
    private let getConversationLabelUseCase = GetConversationLabelUseCase()
    private let getUserUseCase = GetUserUseCase()
    private let getContactNicknameUseCase = GetContactNicknameUseCase()
    private let observeNextMessageUseCase = ObserveNextMessageUseCase()
    private let persistSendingMessageUseCase = PersistSendingMessageUseCase()
    
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
                                self.observeNextMessage(fromLastId: messageItems.first?.messageId, withTracker: errorTracker)
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
                        
                        self.handleSend(localMessage: message, withTracker: errorTracker)
                        
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
        
        return Output (
            error: errorTracker.asDriver())
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
                                self.observeNextMessage(fromLastId: messageItems.first?.messageId, withTracker: errorTracker)
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
                        
                        self.handleSend(localMessage: message, withTracker: errorTracker)
                        
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
                        self.handleSend(localMessage: message, withTracker: errorTracker)
                        
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
            error: errorTracker.asDriver())
    }
    
    private func notifyItems(with items: [MessageItem]) {
        lastMessTime = Int64(items.first?.messageData["at-time"] ?? "\(lastMessTime)") ?? lastMessTime
        self.displayLogic?.onNewData(items: items)
    }
    
    private func notifySingleItem(with item: MessageItem) {
        self.lastMessTime = Int64(item.messageData["at-time"] ?? "\(self.lastMessTime)") ?? self.lastMessTime
        self.displayLogic?.onNewSingleData(item: item)
    }
    
    private func handleSend(localMessage: Message, withTracker errorTracker: ErrorTracker) {
        let request = PersistSendingMessageRequest(message: localMessage)
        self.persistSendingMessageUseCase
            .execute(request: request)
            .do(onNext: { [unowned self] (message) in
                self.displayLogic?.onNewSingleData(item: self.convert(localMessage: localMessage))
            })
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
            .drive()
            .disposed(by: self.disposeBag)
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
        var data = [String : String]()
        data["mess-id"] = url.lastPathComponent
        data["local-id"] = url.lastPathComponent
        data["content"] = url.path
        data["at-time"] = self.getTime()
        data["type"] = "image"
        data["sent-by"] = user.userId
        return Message(type: .image, data: data)
    }
    
    private func convert(localMessage: Message) -> MessageItem {
        let localData = localMessage.data
        let messId = localData["mess-id"]!
        switch localMessage.type {
        case .image:
            return MessageItem(messageType: .imageMe, messageId: messId, messageData: localData, isSending: true)
        case .text:
            return MessageItem(messageType: .textMe, messageId: messId, messageData: localData, isSending: true)
        }
    }
    
    private func convert(messages: [Message], user: User) -> [MessageItem] {
        var res: [MessageItem] = []
        for m in messages {
            let messid = m.data["mess-id"]!
            switch m.type {
            case .image:
                if m.data["sent-by"]!.elementsEqual(user.userId) {
                    res.append(MessageItem(messageType: .imageMe, messageId: messid, messageData: m.data))
                } else {
                    res.append(MessageItem(messageType: .image, messageId: messid, messageData: m.data))
                }
                
            case .text:
                if m.data["sent-by"]!.elementsEqual(user.userId) {
                    res.append(MessageItem(messageType: .textMe, messageId: messid, messageData: m.data))
                } else {
                    res.append(MessageItem(messageType: .text, messageId: messid, messageData: m.data))
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
        return Message(type: .text, data: data)
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
    }
    
    enum Item {
        case text(message: Message)
        case textMe(message: Message)
        case image(message: Message)
        case imageMe(message: Message)
    }
}
