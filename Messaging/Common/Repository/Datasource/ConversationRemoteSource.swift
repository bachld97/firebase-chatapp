import RxSwift

protocol ConversationRemoteSource {
    func loadChatHistory(of user: User) -> Observable<[Conversation]>
    func loadMessages(of user: User, with contact: Contact) -> Observable<[Message]>
    func loadMessages(of conversationId: String) -> Observable<[Message]>
    func sendMessage(message: Message, to conversation: String, genId: Bool) -> Observable<Bool>
    func sendMessage(message: Message, from user: User, to contact: Contact) -> Observable<Bool>
    
    func observeNextMessage(for user: User, fromLastId lastId: String?) -> Observable<Message>
//    func getConversationLabel(conversationId: String) -> Observable<String>
    func getContactNickname(user: User, contact: Contact) -> Observable<String>
}

class ConversationRemoteSourceFactory {
    public static let sharedInstance: ConversationRemoteSource = ConversationFirebaseSource2()
}
