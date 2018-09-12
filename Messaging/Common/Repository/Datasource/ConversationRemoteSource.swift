import RxSwift

protocol ConversationRemoteSource {
    func loadChatHistory(of user: User) -> Observable<[Conversation]>
    func loadMessages(of user: User, with contact: Contact) -> Observable<[Message]>
    func loadMessages(of conversationId: String) -> Observable<[Message]>
    func sendMessage(message: Message, to conversation: String) -> Observable<Bool>
    func sendMessage(message: Message, from user: User, to contact: Contact) -> Observable<Bool>
    
    
//    func getConversationLabel(conversationId: String) -> Observable<String>
//    func getContactNickname(contact: Contact) -> Observable<String>
}

class ConversationRemoteSourceFactory {
    public static let sharedInstance: ConversationRemoteSource = ConversationFirebaseSource()
}
