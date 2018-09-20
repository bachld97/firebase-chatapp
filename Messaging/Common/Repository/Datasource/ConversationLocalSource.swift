import RxSwift

protocol ConversationLocalSource {
    func loadMessages(of user: User, with contact: Contact) -> Observable<[Message]>
    func loadMessages(of conversationId: String) -> Observable<[Message]>
    
    func persistMessages(_ messages: [Message]) -> Observable<Bool>
}

class ConversationLocalSourceFactory {
    public static let sharedInstance: ConversationLocalSource = ConversationLocalSourceImpl()
}

class ConversationLocalSourceImpl: ConversationLocalSource {
    func loadMessages(of conversationId: String) -> Observable<[Message]> {
        return Observable.just([])
    }
    
    func persistMessages(_ messages: [Message]) -> Observable<Bool> {
        return Observable.just(true)
    }
    
    func loadMessages(of user: User, with contact: Contact) -> Observable<[Message]> {
        return Observable.just([])
    }
}
