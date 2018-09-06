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
        return Observable.just([])
    }
}
