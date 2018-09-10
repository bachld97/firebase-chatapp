import RxSwift

protocol ConversationRemoteSource {
    func loadChatHistory(of user: User) -> Observable<[Conversation]>
    func loadMessages(of user: User, with contactId: String) -> Observable<[Message]>
    func loadMessages(of conversationId: String) -> Observable<[Message]>
}

class ConversationRemoteSourceFactory {
    public static let sharedInstance: ConversationRemoteSource = ConversationFirebaseSource()
}
