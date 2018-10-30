import RxSwift
import RxCocoa
import DeepDiff

protocol SeeConversationDisplayLogic : class {
    func goBack()
    func clearText()
    func goPickMedia()
    func goPickContact()
    func goPickLocation()
    func goPickDocument()
    
    func notifyItems(with changes: [Change<MessageItem>]?)
    func notifyItem(with addRespond: (Bool, Int))
    
    func goShowImage(_ imageUrl: String)
    func goShowContact(_ contactId: String)
    func goShowLocation(lat: Double, long: Double)
    
    func notifyTextCopied(with text: String)
    func notifyFileDownloaded(_ name: String)
    
    func viewFile(withUrl url: URL, withName name: String)
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
    
    private let downloadFileUsecase = DownloadFileUseCase()
    private let fileDownloadPublish = PublishSubject<(String,String)>()
    
    private let sendMessageDisplay = Variable("Send")
    
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
    private let thumbsUpText: String
    
    init(displayLogic: SeeConversationDisplayLogic, contactItem: ContactItem) {
        self.displayLogic = displayLogic
        self.contactItem = contactItem
        self.disposeBag = DisposeBag()
        self.conversationItem = nil
        self.dataSource = MessasgeItemDataSource(resendMessagePublish, messageClickPublish)
        
        thumbsUpText = "\(UnicodeScalar(0x1f44d)!)"
    }
    
    init(displayLogic: SeeConversationDisplayLogic, conversationItem: ConversationItem) {
        self.displayLogic = displayLogic
        self.conversationItem = conversationItem
        self.disposeBag = DisposeBag()
        self.contactItem = nil
        self.dataSource = MessasgeItemDataSource(resendMessagePublish, messageClickPublish)
        thumbsUpText = "\(UnicodeScalar(0x1f44d)!)"
    }
    
    func transform(input: Input) -> Output {
        
        (input.textMessage <-> self.textMessageContent)
            .disposed(by: self.disposeBag)
        
        (input.sendMessDisplay <-> self.sendMessageDisplay)
            .disposed(by: self.disposeBag)
        
        if contactItem != nil {
            return transformWithContactItem(
                input: input, contactItem: contactItem!)
        }
        
        if conversationItem != nil {
            return transformWithConversationItem(
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
                                let message = self.createLikeMessage(user)
                               
                                return self.sendMessageToUserUseCase
                                    .execute(request: SendMessageToUserRequest(
                                        message: message,
                                        toUser: contactItem.contact))
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
        

        input.pickContactTrigger
            .drive(onNext: { [unowned self] (_) in
                self.displayLogic?.goPickContact()
            })
            .disposed(by: self.disposeBag)
        
        input.pickLocationTrigger
            .drive(onNext: { [unowned self] (_) in
                self.displayLogic?.goPickLocation()
            })
            .disposed(by: self.disposeBag)
        
        self.messageClickPublish
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [unowned self] (messageItem) in
                self.handleMessageClick(messageItem)
            })
            .disposed(by: self.disposeBag)
        
        return Output (error: errorTracker.asDriver(), dataSource: self.dataSource)
    }
    
    func transformWithConversationItem(input: Input, conversationItem: ConversationItem) -> Output {
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
                                let message = self.createLikeMessage(user)
                                return self.sendMessageUseCase
                                    .execute(request: SendMessageRequest(
                                        message: message,
                                        conversationId: conversationItem.conversation.id))
                        }
                        
                        let message = self.parseTextMessage(user)
                        self.displayLogic?.clearText()
                        self.textMessageContent.accept("")
                        self.sendMessageDisplay.value = self.thumbsUpText

                        
                        return self.sendMessageUseCase
                            .execute(request: SendMessageRequest(
                                message: message,
                                conversationId: conversationItem.conversation.id))
                    }
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
                
            }
            .drive( )
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
        
        input.pickLocationTrigger
            .drive(onNext: { [unowned self] (_) in
                self.displayLogic?.goPickLocation()
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
        
        
        input.sendLocationPublish
            .flatMap { [unowned self] (lat, long) -> Driver<Bool> in
                return self.getUserUseCase.execute(request: ())
                    .flatMap { [unowned self] (user) -> Observable<Bool> in
                        
                        let message = self.parseLocationMessage(user, lat, long)
                        
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
        
        input.sendEmojiPublish
            .drive(onNext: { [unowned self] (emojiString) in
                let oldString = self.textMessageContent.value
                self.textMessageContent.accept("\(oldString)\(emojiString)")
                self.sendMessageDisplay.value = "Send"
            })
            .disposed(by: self.disposeBag)
        
        input.textMessage
            .asDriver()
            .drive(onNext: { [unowned self] (s) in
                if s.isEmpty {
                    self.sendMessageDisplay.value = self.thumbsUpText
                } else {
                    self.sendMessageDisplay.value = "Send"
                }
            })
            .disposed(by: self.disposeBag)
        
        
        input.pickDocumentTrigger
            .drive(onNext: { [unowned self] (_) in
                self.displayLogic?.goPickDocument()
            })
            .disposed(by: self.disposeBag)
        
        input.sendFilePublish
            .flatMap { [unowned self] (url) -> Driver<Bool> in
                return self.getUserUseCase.execute(request: ())
                    .flatMap { [unowned self] (user) -> Observable<Bool> in
                        
                        let message = self.parseFileMessage(user, url)
                        
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
        
        self.fileDownloadPublish
            .asDriverOnErrorJustComplete()
            .flatMap { [unowned self] (id, name) in
                // TODO: Check if file already downloaded
                // If downloaded just return
                // return Observable.just(name)
                let request = DownloadFileRequest(messageId: id, fileName: name)
                return self.downloadFileUsecase
                    .execute(request: request)
                    .do()
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive(onNext: { [unowned self] (name) in
                self.displayLogic?.notifyFileDownloaded(name)
            })
            .disposed(by: self.disposeBag)
        
        return Output(
            error: errorTracker.asDriver(), dataSource: self.dataSource)
    }
    
    private func handleMessageClick(_ messageItem: MessageItem) {
        switch messageItem.message.type {
        case .file:
            let fileName = messageItem.message.getContent()
            let messageId = messageItem.message.getMessageId()
            let ext = String(fileName.split(separator: ".").last!)
            let fileNameExt = "\(messageId).\(ext)"
            
            if FileUtil.fileExists(fileNameExt) {
                let fileToView = FileUtil.getSaveUrl(for: fileNameExt)
                self.displayLogic?.viewFile(withUrl: fileToView, withName: fileName)
            } else {
                self.fileDownloadPublish.onNext((messageId, fileName))
            }
        case .location:
            let coord = messageItem.message.getContent().split(separator: "_")
            let lat = Double(coord.first!)!
            let long = Double(coord.last!)!
            self.displayLogic?.goShowLocation(lat: lat, long: long)
        case .image:
            self.displayLogic?.goShowImage(messageItem.message.getContent())
        case .text:
            self.displayLogic?.notifyTextCopied(with: messageItem.message.content)
        case .contact:
            let id = messageItem.message.content
            if id.contains("#") {
                self.displayLogic?.goShowContact(String(id.split(separator: "#").first!))
            } else {
                self.displayLogic?.goShowContact(id)
            }
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
    
    private func parseFileMessage(_ user: User, _ url: URL) -> Message {
        // let name = url.lastPathComponent
        return Message(type: .file, convId: nil, content: url.path,
                       atTime: self.getTime(), sentBy: user.userId,
                       messId: url.lastPathComponent, isSending: true)
    }
    
    private func parseImageMessage(_ user: User, _ url: URL) -> Message {
        return Message(type: .image, convId: nil, content: url.path,
                       atTime: self.getTime(), sentBy: user.userId,
                       messId: url.lastPathComponent, isSending: true)
    }
    
    private func parseLocationMessage(_ user: User,
                                      _ lat: Double, _ long: Double) -> Message {
        return Message(type: .location,
                       convId: nil,
                       content: "\(lat)_\(long)",
                       atTime: self.getTime(),
                       sentBy: user.userId,
                       messId: nil)
    }
    
    private func parseContactMessage(_ user: User, _ contact: Contact) -> Message {

        return ContactMessage(contact: contact, senderId: user.userId, atTime: self.getTime(),
                              isSending: true)
    }
    
    private func convert(localMessage: Message) -> MessageItem {
        switch localMessage.type {
        case .file:
            return MessageItem(messageItemType: .fileMe, message: localMessage)
        case .location:
            return MessageItem(messageItemType: .locationMe, message: localMessage)
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
            case .file:
                if m.getSentBy().elementsEqual(user.userId) {
                    res.append(MessageItem(messageItemType: .fileMe, message: m, showTime: showTime))
                } else {
                    res.append(MessageItem(messageItemType: .file, message: m, showTime: showTime))
                }
            case .location:
                if m.getSentBy().elementsEqual(user.userId) {
                    res.append(MessageItem(messageItemType: .locationMe, message: m, showTime: showTime))
                } else {
                    res.append(MessageItem(messageItemType: .location, message: m, showTime: showTime))
                }
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
    
    private func createLikeMessage(_ user: User) -> Message {
        let content = thumbsUpText
        
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
        let sendMessDisplay: Variable<String>
        let conversationLabel: Binder<String?>
        let textMessage: ControlProperty<String>
        let pickImageTrigger: Driver<Void>
        let pickContactTrigger: Driver<Void>
        let pickLocationTrigger: Driver<Void>
        let pickDocumentTrigger: Driver<Void>
        let sendImagePublish: Driver<URL>
        let sendContactPublish: Driver<Contact>
        let sendLocationPublish: Driver<(Double, Double)>
        let sendEmojiPublish: Driver<String>
        let sendFilePublish: Driver<URL>
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
