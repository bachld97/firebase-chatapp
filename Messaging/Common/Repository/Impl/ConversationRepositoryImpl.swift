import RxSwift

class ConversationRepositoryImpl : ConversationRepository {
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
                    
                    return self.remoteSource
                        .loadMessages(of: user, with: contact)
            }
        }
    }
    
    func loadMessages(of conversationId: String) -> Observable<[Message]> { 
        return Observable.deferred {
            
            return self.remoteSource
                .loadMessages(of: conversationId)
        }
    }
}
