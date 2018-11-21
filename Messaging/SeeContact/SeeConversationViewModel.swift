import RxSwift
import RxCocoa
import DeepDiff


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
    private let sendMessageText = BehaviorRelay<String>(value: "Send")
    
    // Click on the resend button
    private let resendMessagePublish = PublishSubject<MessageItem>()
    // click on the message themselves, for ex: text = copy, image = show, etc.
    private let messageClickPublish = PublishSubject<MessageItem>()
    
    private let messageConverter = MessageConverter()
    private let messageParser = MessageParser()
    private let thumbsUpText: String = "\(UnicodeScalar(0x1f44d)!)"

    private let audioController = AudioController()
    
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
                        let conversationId = ConvId.get(for: user, with: contactItem.contact)
                        return self.sendMessageUseCase
                            .execute(request: SendMessageRequest(
                                message: message,
                                conversationId: conversationId))
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
                        
                        let conversationId = ConvId.get(for: user, with: contactItem.contact)
                        return self.sendMessageUseCase
                            .execute(request: SendMessageRequest(
                                message: message,
                                conversationId: conversationId))
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
                        
                        let conversationId = ConvId.get(for: user, with: contactItem.contact)
                        return self.sendMessageUseCase
                            .execute(request: SendMessageRequest(
                                message: message,
                                conversationId: conversationId))
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
        
        
        input.cleanupTrigger
            .drive(onNext: { [unowned self] (_) in
                self.cleanup()
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
        
        
        input.cleanupTrigger
            .drive(onNext: { [unowned self] (_) in
                self.cleanup()
            })
            .disposed(by: self.disposeBag)

        return Output(
            error: errorTracker.asDriver(), dataSource: self.dataSource)
    }
    
    
    private func cleanup() {
        stopPlayingAudio()
        self.audioController.stopAudio()
    }
    
    
    private func handleMessageClick(_ messageItem: MessageItem) {
        switch messageItem.message.type {
        case .video:
            self.handleVideoMessage(messageItem)
        case .audio:
            self.handleAudioMessage(messageItem)
        case .file:
            // self.stopPlayingAudio()
            self.handleDocumentMessage(messageItem)
        case .location:
            // self.stopPlayingAudio()
            self.handleLocationMessage(messageItem)
        case .image:
            // self.stopPlayingAudio()
            self.handleImageMessage(messageItem)
        case .text:
            self.handleTextMessage(messageItem)
        case .contact:
            // self.stopPlayingAudio()
            self.handleContactMessage(messageItem)
        }
    }
    
    private func handleVideoMessage(_ messageItem: MessageItem) {
        let videoUrl = UrlBuilder.buildUrl(forVideoMessage: messageItem.message.getMessageId())
        self.displayLogic?.goVideoPlayer(videoUrl: videoUrl)
    }
    
    private func stopPlayingAudio() {
        guard previouslyPlayingAudioMessage != nil else {
            return
        }
        
        let oldAudioMessage = previouslyPlayingAudioMessage!
        oldAudioMessage.isPlaying = false
        let response = self.dataSource.addOrUpdateSingleItem(item: oldAudioMessage)
        self.audioController.pauseAudio()
        self.displayLogic?.notifyItem(with: response)
        previouslyPlayingAudioMessage = nil
    }
    
    private var previouslyPlayingAudioMessage : AudioMessageItem?
    private func handleAudioMessage(_ messageItem: MessageItem) {
        guard let audioMessage = messageItem as? AudioMessageItem else {
            return
        }

        if self.previouslyPlayingAudioMessage == nil {
            self.justPlayAudio(url: URL(string: audioMessage.message.getContent()))
            self.previouslyPlayingAudioMessage = audioMessage
        } else {
            let oldAudioMessage = self.previouslyPlayingAudioMessage!
            if oldAudioMessage.message.getMessageId()
                .elementsEqual(audioMessage.message.getMessageId()) {
                // Same audio, should toggle
                if oldAudioMessage.isPlaying {
                    self.audioController.resumeAudio()
                } else {
                    self.audioController.pauseAudio()
                }
            } else {
                // Different audio, should stop old if isPlaying
                oldAudioMessage.isPlaying = false
                let response = self.dataSource.addOrUpdateSingleItem(item: oldAudioMessage)
                self.displayLogic?.notifyItem(with: response)

                // Start new one
                self.justPlayAudio(url: URL(string: audioMessage.message.getContent()))
                self.previouslyPlayingAudioMessage = audioMessage
            }
        }
    }
    
    private func justPlayAudio(url: URL?) {
        guard let unwrappedUrl = url else {
            // self.displayLogic?.reportAudioError()
            return
        }
        
        self.audioController.playAudio(url: unwrappedUrl)
    }
    
    private func handleDocumentMessage(_ messageItem: MessageItem) {
        let fileName = messageItem.message.getContent()
        let messageId = messageItem.message.getMessageId()
        let ext = String(fileName.split(separator: ".").last!)
        let fileNameExt = "\(messageId).\(ext)"
        
        if FileUtil.fileExists(fileNameExt) {
            let fileToView = FileUtil.getSaveUrl(for: fileNameExt)
            self.displayLogic?.viewFile(withUrl: fileToView, withName: fileName)
        } else {
            self.fileDownloadPublish.onNext((messageId, fileName))
            let updateItem = DocumentMessageItem(
                messageItemType: messageItem.messageItemType,
                message: messageItem.message,
                isDocumentDownloaded: true,
                showTime: messageItem.showTime)
            let updateInfo = self.dataSource.addOrUpdateSingleItem(item: updateItem)
            self.displayLogic?.notifyItem(with: updateInfo)
        }
    }
    
    private func handleLocationMessage(_ messageItem: MessageItem) {
        let coord = messageItem.message.getContent().split(separator: "_")
        let lat = Double(coord.first!)!
        let long = Double(coord.last!)!
        self.displayLogic?.goShowLocation(lat: lat, long: long)
        
    }
    
    private func handleImageMessage(_ messageItem: MessageItem) {
        self.displayLogic?.goShowImage(messageItem.message.getContent())
    }
    
    private func handleTextMessage(_ messageItem: MessageItem) {
        self.displayLogic?.notifyTextCopied(with: messageItem.message.content)
    }
    
    private func handleContactMessage(_ messageItem: MessageItem) {
        let id = messageItem.message.content
        if id.contains("#") {
            self.displayLogic?.goShowContact(String(id.split(separator: "#").first!))
        } else {
            self.displayLogic?.goShowContact(id)
        }
    }
    
    private func notifyItems(with items: [MessageItem]) {
        self.messageParser.updateTime(items.first)
        
        DispatchQueue.main.async {
            let changes = self.dataSource.setItems(items: items)
            self.displayLogic?.notifyItems(with: changes)
        }
    }
    
    private func notifySingleItem(with item: MessageItem) {
        self.messageParser.updateTime(item)
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
        return self.messageParser.parseFileMessage(user, url)
    }
    
    private func parseImageMessage(_ user: User, _ url: URL) -> Message {
        return self.messageParser.parseImageMessage(user, url)
    }
    
    private func parseLocationMessage(_ user: User,
                                      _ lat: Double, _ long: Double) -> Message {
        return self.messageParser.parseLocationMessage(user, lat, long)
    }
    
    private func parseContactMessage(_ user: User, _ contact: Contact) -> Message {
        return self.messageParser.parseContactMessage(user, contact)
    }
    
    private func convert(localMessage: Message) -> MessageItem {
        return self.messageConverter.convert(localMessage: localMessage)
    }
    
    private func convert(messages: [Message], user: User) -> [MessageItem] {
        return self.messageConverter.convert(messages: messages, user: user)
    }
    
    private func parseTextMessage(_ user: User) -> Message {
        let content = self.textMessageContent.value
                .trimmingCharacters(in: .whitespacesAndNewlines)
        return self.messageParser.parseTextMessage(user, content)
    }
    
    private func createLikeMessage(_ user: User) -> Message {
        return self.messageParser.createLikeMessage(user)
    }
}

extension SeeConversationViewModel {
    struct Input {
        let trigger: Driver<Void>
        let cleanupTrigger: Driver<Void>
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
    func goVideoPlayer(videoUrl: URL)
}
