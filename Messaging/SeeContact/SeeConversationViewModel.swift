import RxSwift
import RxCocoa
import DeepDiff

protocol SeeConversationDisplayLogic : class {
    func goBack()
    func clearText()
    func goPickMedia()
    func goPickContact()
    
    func notifyItems(with changes: [Change<MessageItem>]?)
    func notifyItem(with addRespond: (Bool, Int))
    
    func goShowImage(_ imageUrl: String)
    func notifyTextCopied(with text: String)
}

class SeeConversationViewModel : ViewModelDelegate {
    private weak var displayLogic: SeeConversationDisplayLogic?
    private let disposeBag: DisposeBag
    
    let contactItem: ContactItem?
    let conversationItem: ConversationItem?
    
    let textMessageContent = BehaviorRelay<String>(value: "")
    
    private let dataSource: MessasgeItemDataSource
    
    private let loadConvoFromContactIdUseCase = LoadConvoFromContactIdUseCase()
    private let loadConvoFromConvoIdUseCase = LoadConvoFromConvoIdUseCase()
    private let sendMessageUseCase = SendMessageUseCase()
    private let sendMessageToUserUseCase = SendMessageToUserUseCase()
    private let getConversationLabelUseCase = GetConversationLabelUseCase()
    private let getUserUseCase = GetUserUseCase()
    private let getContactNicknameUseCase = GetContactNicknameUseCase()
    private let observeNextMessageUseCase = ObserveNextMessageUseCase()
    private let resendUseCase = ResendUseCase()
    
    
    // Click on the resend button
    private let resendMessagePublish = PublishSubject<MessageItem>()
    // click on the message themselves, for ex: text = copy, image = show, etc.
    private let messageClickPublish = PublishSubject<MessageItem>()
    
    /* We falsely use timestamp of last message
     * and offset it by 1 to create timestamp
     * of new message on local storage
     * because we don't need time accuracy
     * we just need to preserve order
     * This value is overriden by server time anyway.
     */
    private var lastMessTime: Int64 = 0
    
    init(displayLogic: SeeConversationDisplayLogic, contactItem: ContactItem) {
        self.displayLogic = displayLogic
        self.contactItem = contactItem
        self.disposeBag = DisposeBag()
        self.conversationItem = nil
        self.dataSource = MessasgeItemDataSource(resendMessagePublish, messageClickPublish)
    }
    
    init(displayLogic: SeeConversationDisplayLogic, conversationItem: ConversationItem) {
        self.displayLogic = displayLogic
        self.conversationItem = conversationItem
        self.disposeBag = DisposeBag()
        self.contactItem = nil
        self.dataSource = MessasgeItemDataSource(resendMessagePublish, messageClickPublish)
    }
    
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
    
    func transformWithContactItem(input: Input, contactItem: ContactItem) -> Output {
        let errorTracker = ErrorTracker()
        
        input.trigger
            .flatMap { [unowned self] (_) -> Driver<[MessageItem]> in
                let request = LoadConvoFromContactRequest(contact: contactItem.contact)
                
                return self.getUserUseCase
                    .execute(request: ())
                    .flatMap { [unowned self] (user) -> Observable<[MessageItem]> in
                        return self.loadConvoFromContactIdUseCase
                            .execute(request: request)
                            .do()
                            .flatMap {[unowned self] (messages) -> Observable<[MessageItem]> in
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
        
        input.pickImageTrigger
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
        
        self.resendMessagePublish
            .asDriverOnErrorJustComplete()
            .flatMap { [unowned self] (msgItem) -> Driver<Bool> in
                let request = ResendRequest(message: msgItem.message)
                return self.resendUseCase
                    .execute(request: request)
                    .do()
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)
        
        self.messageClickPublish
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [unowned self] (messageItem) in
                self.handleMessageClick(messageItem)
            })
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
        
        input.pickImageTrigger
            .drive(onNext: { [unowned self] (_) in
                self.displayLogic?.goPickMedia()
            })
            .disposed(by: self.disposeBag)
        
        input.pickContactTrigger
            .drive(onNext: { [unowned self] (_) in
                self.displayLogic?.goPickContact()
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
        
        self.messageClickPublish
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [unowned self] (messageItem) in
                    self.handleMessageClick(messageItem)
            })
            .disposed(by: self.disposeBag)
        
        
        self.resendMessagePublish
            .asDriverOnErrorJustComplete()
            .flatMap { [unowned self] (msgItem) -> Driver<Bool> in
                let request = ResendRequest(message: msgItem.message)
                return self.resendUseCase
                    .execute(request: request)
                    .do()
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)
        
        input.sendContactPublish
            .flatMap { [unowned self] (contact) -> Driver<Bool> in
                return self.getUserUseCase.execute(request: ())
                    .flatMap { [unowned self] (user) -> Observable<Bool> in
                        
                        let message = self.parseContactMessage(user, contact)
                        
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
    
    private func handleMessageClick(_ messageItem: MessageItem) {
        
        switch messageItem.message.type {
        case .image:
            self.displayLogic?.goShowImage(messageItem.message.getContent())
        case .text:
            self.displayLogic?.notifyTextCopied(with: messageItem.message.content)
        case .contact:
            print("Contact clicked: ID")
        }
    }
    
    private func notifyItems(with items: [MessageItem]) {
        lastMessTime = Int64(items.first?.message.getAtTime() ?? "\(lastMessTime)") ?? lastMessTime
        
        DispatchQueue.main.async {
            let changes = self.dataSource.setItems(items: items)
            self.displayLogic?.notifyItems(with: changes)
        }
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
                    .execute(request: ())
                    .map { (message) -> (Message, User) in
                        return (message, user)
                    }
                    .do(onNext: { [weak self] (mess, user) in
                        let item = self?.convert(messages: [mess], user: user).first
                        if item != nil {
                            self?.notifySingleItem(with: item!)
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
    
    private func parseContactMessage(_ user: User, _ contact: Contact) -> Message {
//        return Message(type: .contact, convId: nil, content: contact.userId,
//                       atTime: self.getTime(), sentBy: user.userId,
//                       messId: "", isSending: true)
        // TODO: return ContactMessage
        return ContactMessage(contact: contact, user: user, atTime: self.getTime(),
                              isSending: true)
    }
    
    private func convert(localMessage: Message) -> MessageItem {
        switch localMessage.type {
        case .image:
            return MessageItem(messageItemType: .imageMe, message: localMessage)
        case .text:
            return MessageItem(messageItemType: .textMe, message: localMessage)
        case .contact:
            return MessageItem(messageItemType: .contactMe, message: localMessage)
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
            case .contact:
                if m.getSentBy().elementsEqual(user.userId) {
                    res.append(MessageItem(messageItemType: .contactMe, message: m, showTime: showTime))
                } else {
                    res.append(MessageItem(messageItemType: .contact, message: m, showTime: showTime))
                }
            }
        }
        
        return res
    }
    
    private func parseTextMessage(_ user: User) -> Message {
        let content = self.textMessageContent.value
                .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return Message(type: .text,
                       convId: nil,
                       content: content,
                       atTime: self.getTime(),
                       sentBy: user.userId,
                       messId: nil)
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
        let pickImageTrigger: Driver<Void>
        let pickContactTrigger: Driver<Void>
        let sendImagePublish: Driver<URL>
        let sendContactPublish: Driver<Contact>
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
