import RxSwift

protocol ConversationRepository {
    func loadChatHistory() -> Observable<[Conversation]>
    func loadMessages(with contact: Contact) -> Observable<[Message]>
    func loadMessages(of conversationId: String) -> Observable<[Message]>
    func sendMessage(request: SendMessageRequest) -> Observable<Bool>
    func sendMessageToUser(request: SendMessageToUserRequest) -> Observable<Bool>
}

class ConversationRepositoryFactory {
    public static let sharedInstance = ConversationRepositoryImpl(
        userRepository: UserRepositoryFactory.sharedInstance,
        localSource: ConversationLocalSourceFactory.sharedInstance,
        remoteSource: ConversationRemoteSourceFactory.sharedInstance)
}
