import RealmSwift
import RxSwift

class ConversationRealmSource : ConversationLocalSource {
    func loadMessages(of user: User, with contact: Contact) -> Observable<[Message]> { 
        return self.loadMessages(of: ConvId.get(for: user, with: contact))
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
                messages.forEach { (message) in
                    guard let localId = message.data["local-id"] else {
                        realm.add(MessageRealm.from(message, with: conversationId), update: true)
                        return
                    }
                    
                    let localMessage = realm.objects(MessageRealm.self)
                        .filter("conversationId == %@ and messageId == %@",
                                conversationId, localId)
                        .first
                    
                    
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
            }
            return Observable.just(messages)
        }
    }
    
    func persistMessage(_ message: Message, with conversationId: String) -> Observable<Message> {
        return Observable.deferred {
            let realm = try Realm()
            try realm.write {
                let localMessage = realm.objects(MessageRealm.self)
                    .filter("conversationId == %@ and messageId == %@",
                            conversationId, message.data["local-id"]!)
                    .first
            
            
                guard let mess = localMessage else {
                    // Check ID now
                    let localMessage2 = realm.objects(MessageRealm.self)
                        .filter("conversationId == %@ and messageId == %@",
                                conversationId, message.data["mess-id"]!)
                        .first
                    
                    guard localMessage2 != nil else {
                        realm.add(MessageRealm.from(message, with: conversationId), update: true)
                        return
                    }
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
                newMess.isSending = message.isSending
                
                realm.delete(mess)
                realm.add(newMess, update: true)
            }
            return Observable.just(message)
        }
    }
}
