import RxSwift
import FirebaseDatabase

class ConversationFirebaseSource: ConversationRemoteSource {
    
    var ref: DatabaseReference!
    
    init() {
        ref = Database.database().reference()
    }
    
    func loadMessages(of conversationId: String) -> Observable<[Message]> {
        return Observable.create { [unowned self] (observer) in
            let dbRequest = self.ref
                .child("conversations/\(conversationId)/messages")
                .observe(.value, with: { (snapshot) in
                    
                    // Iterate over the messages
                    guard let bigDict = snapshot.value as? [String: Any] else {
                        observer.onNext([])
                        return
                    }
                    
                    // var messages: [Message] = []
                    for (messId, messValue) in bigDict {
                        guard let messageDict = messValue as? [String : String] else {
                            continue
                        }
                        
                        print("\(messId): \(messageDict)")
                    }
                    
                    // observer.onNext(messages) 
                }, withCancel: { (error) in
                    observer.onError(error)
                })
            

            return Disposables.create {
                self.ref.child("conversations/\(conversationId)/messages")
                    .removeObserver(withHandle: dbRequest)
            }
        }
    }
    
    func loadMessages(of user: User, with contactId: String) -> Observable<[Message]> {
        return Observable.create { (_) in
            
            return Disposables.create {
                
            }
        }
    }
    

    func loadChatHistory(of user: User) -> Observable<[Conversation]> {
        return Observable.create { [unowned self] (obs) in
            let  dbRequest = self.ref.child("conversations")
                .queryOrdered(byChild: "users/\(user.userId)/avail")
                .queryEqual(toValue: true)
                .observe(.value, with: { (snapshot) in
                    
                    guard snapshot.exists() else {
                        obs.onNext([])
                        return
                    }
                    
                    var items: [Conversation] = []
                    
                    for v in snapshot.children {
                        guard let dict = v as? DataSnapshot else {
                            continue
                        }
                        
                        let item = self.parseConversation(from: dict)
                        
                        if item != nil {
                            items.append(item!)
                        }
                    }
                    
                    print(items.count)
                    obs.onNext(items)
                }, withCancel: { (error) in
                    obs.onError(error)
                })
            
            return Disposables.create { [unowned self] in
                self.ref.child("conversations")
                    .removeObserver(withHandle: dbRequest)
            }
        }
    }
    
    private func parseConversation(from snapshot: DataSnapshot) -> Conversation? {
        
        guard let dict = snapshot.value as? [String: Any] else {
            return nil
        }
        
        guard let lastMessage = dict["last-message"] as? [String : String] else {
            return nil
        }
        
        guard let usersDict = dict["users"] as? [String: Any] else {
            return nil
        }

        let convId = snapshot.key

        guard let isPrivate = dict["is-private"] as? Bool else {
            return nil
        }
        
        let nickname = parseNicknames(from: usersDict)

        guard let message = parseMessage(from: lastMessage) else {
            return nil
        }
        
        let type: ConvoType = isPrivate ? .single : .group
        let res = Conversation(
            id: convId,
            type: type,
            lastMess: message,
            nickname: nickname)
        return res
    }
    
    private func parseNicknames(from userDict: [String: Any]) -> [String: String] {
        var res = [String: String]()
        for (key, value) in userDict {
            res[key] = (value as! [String : Any])["nickname"] as? String ?? key
        }
        return res
    }
    
    private func parseMessage(from messageDict: [String : String]) -> Message? {
        return Message()
    }
}

