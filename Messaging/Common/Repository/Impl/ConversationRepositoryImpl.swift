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
    
    func persistSendingMessage(message: Message) -> Observable<Message> {
        return Observable.deferred { [unowned self] in
            guard let conversationId = self.conversationId else {
                return Observable.just(message)
            }
            
            return self.localSource
                .persistMessage(message, with: conversationId)
        }
    }
    
    func getContactNickname(contact: Contact) -> Observable<String> {
        // return Observable.just("Private")
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
                    
                    return self.remoteSource
                        .loadChatHistory(of: user)
            }
        }
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
                    
                    let uid = [user.userId, contact.userId].sorted()
                        .joined(separator: " ")
                   self.conversationId = uid
                    
                    return self.remoteSource
                        .loadMessages(of: uid)
            }
        }
    }
    
    func observeNextMessage(fromLastId lastId: String?) -> Observable<Message> {
        return Observable.deferred { [unowned self] in
            return self.remoteSource
                .observeNextMessage(fromLastId: lastId)
                .flatMap { [unowned self] (message) -> Observable<Message> in
                    guard let convId = self.conversationId else {
                            return Observable.just(message)
                    }
                    
                    return self.localSource
                        .persistMessage(message, with: convId)
            }
        }
    }
    
    private func mergeMessages(_ localMessages: [Message], _ remoteMessages: [Message]) -> [Message] {
        var res = localMessages
        remoteMessages.forEach { (message) in
            let index = res.firstIndex(where: { (m) in
                return message.data["mess-id"]!
                    .elementsEqual(m.data["mess-id"]!) ||
                    message.data["local-id"]?
                    .elementsEqual(m.data["mess-id"]!) ?? false
            })
            
            if index != nil {
                var newData = res[index!].data
                newData["mess-id"] = message.data["mess-id"]
                // newData["is-sending"] = "1"
                let type = res[index!].type
                res[index!] = Message(type: type, data: newData)
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
            
            return finalStream
                .flatMap { [unowned self]  (messages) in
                    self.localSource
                        .persistMessages(messages, with: conversationId)
            }
        }
    }
}

