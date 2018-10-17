import RxSwift

class ConversationRepositoryImpl : ConversationRepository {
    private var conversationId: String?
    private var lastId: String?
    
    func sendMessage(request: SendMessageRequest) -> Observable<Bool> {
        return remoteSource.sendMessage(message: request.message, to: request.conversationId, genId: true)
    }
    
    func sendMessageToUser(request: SendMessageToUserRequest) -> Observable<Bool> {
        return Observable.deferred { [unowned self] in
            return self.userRepository
                .getUser()
                .take(1)
                .flatMap { [unowned self] (user) -> Observable<Bool> in
                    guard let user = user else {
                        return Observable.error(SessionExpireError())
                    }
                    
                    return self.remoteSource
                        .sendMessage(message: request.message, from: user, to: request.toUser)
            }
        }
    }
    
    func getContactNickname(contact: Contact) -> Observable<String> {
        return Observable.deferred { [unowned self] in
            self.userRepository
                .getUser()
                .take(1)
                .flatMap { (user) -> Observable<String> in
                    guard let user = user else {
                        return Observable.error(SessionExpireError())
                    }
                    
                    return self.remoteSource
                        .getContactNickname(user: user, contact: contact)
            }
        }
    }
    
    func getConversationLabel(conversation: Conversation) -> Observable<String> {
        return Observable.deferred { [unowned self] in
            self.userRepository
                .getUser()
                .take(1)
                .flatMap {  (user) -> Observable<String> in
                    guard let user = user else {
                        return Observable.error(SessionExpireError())
                    }
                    
                    if conversation.id.contains(" ") {
                        let tem = conversation.id.split(separator: " ")
                        var myString: String!
                        if tem[0].elementsEqual(user.userId) {
                            myString = String(tem[1])
                        } else {
                            myString = String(tem[0])
                        }
                        
                        return Observable.just(conversation.nickname[myString]!)
                    } else {
                        return Observable.just("Group chat")
                    }
            }
        }
    }
    
    private let remoteSource: ConversationRemoteSource
    private let localSource: ConversationLocalSource
    private let userRepository: UserRepository
    
    private let disposeBag = DisposeBag()
    
    init(userRepository: UserRepository,
         localSource: ConversationLocalSource,
         remoteSource: ConversationRemoteSource) {
        self.remoteSource = remoteSource
        self.localSource = localSource
        self.userRepository = userRepository
    }
    
    func loadChatHistory() -> Observable<[Conversation]> {
        return Observable.deferred { [unowned self]  in
            return self.userRepository
                .getUser()
                .take(1)
                .flatMap { [unowned self] (user) -> Observable<[Conversation]> in
                    guard let user = user else {
                        return Observable.error(SessionExpireError())
                    }
                    
                    let remoteStream = Observable.just([])
                        .concat(self.remoteSource
                            .loadChatHistory(of: user))
                    
                    let localStream = Observable.just([])
                        .concat(self.localSource
                            .loadChatHistory(of: user))
                    
                    let finalStream = Observable
                        .combineLatest(localStream, remoteStream) { [unowned self] in
                            return self.mergeConversations($0, $1)
                    }
                    
                    return finalStream
                        .flatMap { [unowned self] (conversations) -> Observable<[Conversation]> in
                            return self.localSource
                                .persistConversations(conversations, of: user)
                    }
            }
        }
    }
    
    private func mergeConversations(_ localConversations: [Conversation],
                                    _ remoteConversations: [Conversation]) -> [Conversation] {
        if remoteConversations.count == 0 {
            return localConversations.sorted(by: { $0.compareWith($1) })
        }
        
        var res = remoteConversations
        for (resIndx, it) in res.enumerated() {
            let index = localConversations.firstIndex(where: { (conv) -> Bool in
                it.id.elementsEqual(conv.id)
            })
            
            if index != nil {
                let localCon = localConversations[index!]
                if localCon.lastMess.atTimeAsNum > it.lastMess.atTimeAsNum {
                    res[resIndx] = it.replaceLastMessage(with: localCon.lastMess)
                }
            }
        }
        
        return res.sorted(by: { $0.compareWith($1) })
    }
    
    
    
    func loadMessages(with contact: Contact) -> Observable<[Message]> {
        return Observable.deferred {
            return self.userRepository
                .getUser()
                .take(1)
                .flatMap { [unowned self] (user) -> Observable<[Message]> in
                    guard let user = user else {
                        return Observable.error(SessionExpireError())
                    }
                    let conversationId = ConvId.get(for: user, with: contact)
                    self.conversationId = conversationId
                    let localStream = Observable
                        .just([])
                        .concat(self.localSource.loadMessages(of: conversationId))
                    
                    let remoteStream = Observable
                        .just([])
                        .concat(self.remoteSource.loadMessages(of: user, with: contact))
                    
                    let finalStream = Observable
                        .combineLatest(localStream, remoteStream) { [unowned self] in
                            return self.mergeMessages($0, $1)
                    }
                    
                    return finalStream
                        .flatMap { [unowned self]  (messages) in
                            self.localSource
                                .persistMessages(messages, with: conversationId)
                    }
            }
        }
    }
    
    func observeNextMessage() -> Observable<Message> {
        return Observable.deferred { [unowned self] in
            return self.userRepository
                .getUser()
                .take(1)
                .flatMap { [unowned self] (user) -> Observable<Message> in
                    guard let user = user else {
                        return Observable.error(SessionExpireError())
                    }
                    
                    return self.remoteSource
                        .observeNextMessage(for: user, fromLastId: self.lastId)
                        .flatMap { [unowned self] (message) -> Observable<Message> in
                            guard let convId = self.conversationId else {
                                return Observable.just(message)
                            }
                            
                            if message.getSentBy().elementsEqual(user.userId) && message.type == .image {
                                return self.handleImageSentByMe(message, with: convId)
                            } else {
                                return self.localSource
                                    .persistMessage(message, with: convId)
                            }
                    }
            }
        }
    }
    
    
    private func handleImageSentByMe(_ message: Message, with convId: String) -> Observable<Message> {
        if message.isSending {
            let oldPath = message.getContent()
            guard let lastSegIndex = oldPath.lastIndex(of: "/") else {
                return self.localSource.persistMessage(message, with: convId)
            }
            
            let index = oldPath.distance(from: oldPath.startIndex, to: lastSegIndex) + 1
            let newPath = "\(oldPath[0..<index])\(message.getMessageId())"
            let fm = FileManager()
            do {
                try fm.copyItem(atPath: oldPath, toPath: newPath)
            } catch { }
            
            if fm.fileExists(atPath: newPath) {
                return self.localSource
                    .persistMessage(message.changeContent(withNewContent: newPath),
                                    with: convId)
            }
        }
        
        return self.localSource.persistMessage(message, with: convId)
    }
    
    private func mergeMessages(_ localMessages: [Message], _ remoteMessages: [Message]) -> [Message] {
        self.lastId = remoteMessages.first?.getMessageId()
        
        var res = localMessages
        remoteMessages.forEach { (message) in
            let index = res.firstIndex(where: { 
                return message.getMessageId().elementsEqual($0.getMessageId())
            })
            
            if index != nil {
//                let oldMess = res[index!]
//                let isSending = oldMess.isSending || message.isSending
//                let isFail = oldMess.isFail && message.isFail
//                res[index!] = res[index!].withSendingAndFailStatus(isSending, isFail)
                res[index!] = message
            } else {
                res.append(message)
            }
        }
        
        return res.sorted(by: {
            return $0.compareWith($1)
        })
    }
    
    func loadMessages(of conversationId: String) -> Observable<[Message]> { 
        return Observable.deferred {
            self.conversationId = conversationId
            
            let localStream = Observable
                .just([])
                .concat(self.localSource.loadMessages(of: conversationId))
            
            let remoteStream = Observable
                .just([])
                .concat(self.remoteSource.loadMessages(of: conversationId))
            
            let finalStream = Observable
                .combineLatest(localStream, remoteStream) { [unowned self] in
                    return self.mergeMessages($0, $1)
                }
            
//            let delayedStream = Observable.zip(finalStream, Observable<Int>.interval(RxTimeInterval(1), scheduler: MainScheduler.instance))
//                .flatMap { (items, dur) in
//                    return Observable.just(items)
//            }
            
            return finalStream
                .flatMap { [unowned self]  (messages) in
                    self.retryUnsent(messages, with: conversationId)
                        .flatMap { [unowned self]  (messages) in
                            self.localSource
                                .persistMessages(messages, with: conversationId)
                    }
            }
        }
    }
    
    func resendMessage(request: ResendRequest) -> Observable<Bool> {
        let it = request.message
        return Observable.deferred { [unowned self] in
            guard let conversationId = self.conversationId else {
                return Observable.just(true)
            }
            
            self.remoteSource.sendMessage(message: it, to: conversationId, genId: false)
                .subscribe()
                .disposed(by: self.disposeBag)
            return Observable.just(true)
        }
    }
    
    private func retryUnsent(_ messages: [Message], with conversationId: String) -> Observable<[Message]> {
        return Observable.deferred {
            messages.filter({ (it) -> Bool in
                return it.isSending && !it.isFail
            }).forEach({ [unowned self] (it) in
                self.remoteSource.sendMessage(message: it, to: conversationId, genId: false)
                    .subscribe()
                    .disposed(by: self.disposeBag)
            })
            return Observable.just(messages)
        }
    }
}

