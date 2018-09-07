import RxSwift

class ConversationRepositoryImpl : ConversationRepository {
    
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
                        .loadConversations(of: user)
            }
        }
    }
    
    func loadMessages(with contactId: String) -> Observable<[Message]> {
        return Observable.deferred {
            return Observable.just([])
        }
    }
    
    func loadMessages(of conversationId: String) -> Observable<[Message]> { 
        return Observable.deferred {
            return Observable.just([])
        }
    }
}
