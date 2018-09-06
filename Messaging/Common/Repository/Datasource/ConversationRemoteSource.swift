import RxSwift

protocol ConversationRemoteSource {
    func loadConversations(of user: User) -> Observable<[Conversation]>
//    func loadMessage(withId messageId: String) -> Observable<Message>
}

class ConversationRemoteSourceFactory {
    public static let sharedInstance: ConversationRemoteSource = ConversationFirebaseSource()
}
