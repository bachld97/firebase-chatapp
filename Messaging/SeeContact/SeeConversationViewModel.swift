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
                        
                        self.displayLogic?.onNewSingleData(item: self.convert(localMessage: message))
                        
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
            .flatMap { [unowned self] (_) -> Driver<[Message]> in
                let request = LoadConvoFromConvoIdRequest(convoId: conversationItem.conversation.id)
                
                return self.getUserUseCase
                    .execute(request: ())
                    .flatMap { [unowned self] (user) -> Observable<[Message]> in
                        
                        return self.loadConvoFromConvoIdUseCase
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
                        
                        self.displayLogic?.onNewSingleData(item: self.convert(localMessage: message))
                        
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
                        
                        self.displayLogic?.onNewSingleData(item: self.convert(localMessage: message))
                        
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
                            self.displayLogic?.onNewSingleData(item: item!)
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
        data["local-id"] = url.lastPathComponent
        data["content"] = url.path
        data["type"] = "image"
        data["sent-by"] = user.userId
        return Message(type: .image, data: data)
    }
    
    private func convert(localMessage: Message) -> MessageItem {
        let localData = localMessage.data
        let messId = localData["local-id"]!
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
        let localIdentifier = String(describing: UUID.init())
        var data = [String : String]()
        data["local-id"] = localIdentifier
        data["content"] =
            self.textMessageContent.value
                .trimmingCharacters(in: .whitespacesAndNewlines)
        data["type"] = "text"
        data["sent-by"] = user.userId
        return Message(type: .text, data: data)
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
