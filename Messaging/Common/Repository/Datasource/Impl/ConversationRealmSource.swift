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
            let localMessage = realm.objects(MessageRealm.self)
                .filter("conversationId == %@ and messageId == %@",
                        conversationId, message.data["local-id"]!)
                .first
            
            try realm.write {
                guard let mess = localMessage else {
                    realm.add(MessageRealm.from(message, with: conversationId), update: true)
                    return
                }
                
                // Delete mess
                let newMess = MessageRealm()
                newMess.atTime = mess.atTime
                newMess.content = mess.content
                newMess.conversationId = mess.conversationId
                newMess.sentBy = mess.sentBy
                newMess.type = mess.type
                newMess.messageId = message.data["mess-id"]!
                
                realm.delete(mess)
                realm.add(newMess)
            }
            return Observable.just(message)
        }
    }
}
