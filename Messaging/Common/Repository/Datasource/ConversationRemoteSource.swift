import RxSwift

protocol ConversationRemoteSource {
    func loadConversations(of user: User) -> Observable<[Conversation]>
    func loadMessages(of user: User, with contactId: String) -> Observable<[Message]>
    func loadMessages(of conversationId: String) -> Observable<[Message]>
//    func loadMessage(withId messageId: String) -> Observable<Message>
}

class ConversationRemoteSourceFactory {
    public static let sharedInstance: ConversationRemoteSource = ConversationFirebaseSource()
}
