import RxSwift

protocol ConversationLocalSource {
    func loadChatHistory(of user: User) -> Observable<[Conversation]>
    
    func loadMessages(of user: User, with contact: Contact) -> Observable<[Message]>
    func loadMessages(of conversationId: String) -> Observable<[Message]>
    
    func persistMessages(_ messages: [Message], with conversationId: String) -> Observable<[Message]>
    func persistMessage(_ message: Message, with conversationId: String) -> Observable<Message>
}

class ConversationLocalSourceFactory {
    public static let sharedInstance: ConversationLocalSource = ConversationRealmSource()
}
