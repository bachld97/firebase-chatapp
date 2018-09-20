import RealmSwift
import RxSwift

class ConversationRealmSource : ConversationLocalSource {
    func loadMessages(of user: User, with contact: Contact) -> Observable<[Message]> {
        let uid  = [user.userId, contact.userId].sorted()
            .joined(separator: " ")
        return self.loadMessages(of: uid)
    }
    
    func loadMessages(of conversationId: String) -> Observable<[Message]> {
        return Observable.deferred {
            let realm = try Realm()
            let results = realm.objects(MessageRealm.self)
                .filter("conversationId == %@", conversationId)
                .sorted(byKeyPath: "atTime")
            return Observable.just(results.map { $0.convert()})
        }
    }
    
    func persistMessages(_ messages: [Message], with conversationId: String) -> Observable<[Message]> {
        return Observable.deferred {
            let realm = try Realm()
            try realm.write {
                messages.forEach { (mess) in
                    realm.add(MessageRealm.from(mess, with: conversationId), update: true)
                }
            }
            return Observable.just(messages)
        }
    }
    
    func persistMessage(_ message: Message, with conversationId: String) -> Observable<Message> {
        return Observable.deferred {
            let realm = try Realm()
            try realm.write {
                realm.add(MessageRealm.from(message, with: conversationId), update: true)
            }
            
            return Observable.just(message)
        }
    }
}
