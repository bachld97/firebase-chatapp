import RxSwift

protocol ConversationRemoteSource {
    func loadChatHistory(of user: User) -> Observable<[Conversation]>
    func loadMessages(of user: User, with contact: Contact) -> Observable<[Message]>
    func loadMessages(of conversationId: String) -> Observable<[Message]>
}

class ConversationRemoteSourceFactory {
    public static let sharedInstance: ConversationRemoteSource = ConversationFirebaseSource()
}
