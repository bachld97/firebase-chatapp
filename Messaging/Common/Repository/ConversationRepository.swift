import RxSwift

protocol ConversationRepository {
    func loadChatHistory() -> Observable<[Conversation]>
    func loadMessages(with contactId: String) -> Observable<[Message]>
    func loadMessages(of conversationId: String) -> Observable<[Message]>
}

class ConversationRepositoryFactory {
    public static let sharedInstance = ConversationRepositoryImpl(
        userRepository: UserRepositoryFactory.sharedInstance,
        localSource: ConversationLocalSourceFactory.sharedInstance,
        remoteSource: ConversationRemoteSourceFactory.sharedInstance)
}
