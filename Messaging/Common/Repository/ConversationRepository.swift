import RxSwift

protocol ConversationRepository {
    func loadChatHistory() -> Observable<[Conversation]>
}

class ConversationRepositoryFactory {
    public static let sharedInstance = ConversationRepositoryImpl(
        userRepository: UserRepositoryFactory.sharedInstance,
        localSource: ConversationLocalSourceFactory.sharedInstance,
        remoteSource: ConversationRemoteSourceFactory.sharedInstance)
}
