import RxSwift

protocol ConversationRepository {
    func loadChatHistory() -> Observable<[Conversation]>
    func loadMessages(with contact: Contact) -> Observable<[Message]>
    func loadMessages(of conversationId: String) -> Observable<[Message]>
    func sendMessage(request: SendMessageRequest) -> Observable<Bool>
    func sendMessageToUser(request: SendMessageToUserRequest) -> Observable<Bool>
    
    
    func getConversationLabel(conversation: Conversation) -> Observable<String>
    func getContactNickname(contact: Contact) -> Observable<String>
}

class ConversationRepositoryFactory {
    public static let sharedInstance = ConversationRepositoryImpl(
        userRepository: UserRepositoryFactory.sharedInstance,
        localSource: ConversationLocalSourceFactory.sharedInstance,
        remoteSource: ConversationRemoteSourceFactory.sharedInstance)
}
