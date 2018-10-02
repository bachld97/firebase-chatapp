import RxSwift

class ConversationRepositoryImpl : ConversationRepository {
    private var conversationId: String?
    
    func sendMessage(request: SendMessageRequest) -> Observable<Bool> {
        return remoteSource.sendMessage(message: request.message, to: request.conversationId)
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
                        }.skip(1)
                    
                    return finalStream
                        .flatMap { [unowned self] (conversations) in
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
        return remoteConversations.sorted(by: { $0.compareWith($1) })
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
                        }.skip(1)
                    
                    return finalStream
                        .flatMap { [unowned self]  (messages) in
                            self.localSource
                                .persistMessages(messages, with: conversationId)
                    }
            }
        }
    }
    
    func observeNextMessage(fromLastId lastId: String?) -> Observable<Message> {
        return Observable.deferred { [unowned self] in
            return self.userRepository
                .getUser()
                .take(1)
                .flatMap { [unowned self] (user) -> Observable<Message> in
                    guard let user = user else {
                        return Observable.error(SessionExpireError())
                    }
                    
                    return self.remoteSource
                        .observeNextMessage(for: user, fromLastId: lastId)
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
        var res = localMessages
        remoteMessages.forEach { (message) in
            let index = res.firstIndex(where: { 
                return message.getMessageId().elementsEqual($0.getMessageId())
            })
            
            if index != nil {
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
                }.skip(1)
            
            return finalStream
                .flatMap { [unowned self]  (messages) in
                    self.localSource
                        .persistMessages(messages, with: conversationId)
            }
        }
    }
}

