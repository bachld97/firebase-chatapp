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
                .child("messages/\(conversationId)")
                .queryOrderedByKey()
                .queryLimited(toLast: 10)
                .observe(.value, with: { [unowned self] (snapshot) in
                    
                    // Iterate over the messages
                    guard snapshot.exists() else {
                        observer.onNext([])
                        return
                    }

                    print(snapshot)

                    var messages: [Message] = []
                    let ite = snapshot.children
                    while let snap = ite.nextObject() as? DataSnapshot {
                        guard let messageDict = snap.value as? [String: Any] else {
                            continue
                        }
                        
                        let message = self.parseMessage(from: messageDict)
                        if message != nil {
                            messages.insert(message!, at: 0)
                        }
                    }

                    observer.onNext(messages)
                }, withCancel: { (error) in
                    observer.onError(error)
                })
            
            
            return Disposables.create {
                self.ref.child("conversations/\(conversationId)/messages")
                    .removeObserver(withHandle: dbRequest)
            }
        }
    }
    
    func createConversationIfNotExist(of user: User, with contact: Contact) -> Observable<Bool> {
        return Observable.create { (obs) in
            let uid = [user.userId, contact.userId].sorted()
                .joined(separator: " ")
            
            self.ref.child("conversations/\(uid)")
                .observeSingleEvent(of: .value, with: { [unowned self] (snapshot) in
                    // if snapshot !exist, create that node
                    // else just proceed
                    if !snapshot.exists() {
                        // Create
                        var convDict = [String : Any]()
                        convDict["is-private"] = true
                        
                        var userDict = [String : Any]()
                        userDict["nickname"] = user.userName
                        userDict["avail"] = true
                        
                        var contactDict = [String : Any]()
                        contactDict["nickname"] = contact.userName
                        contactDict["avail"] = true
                        
                        var usersDict = [String : Any]()
                        usersDict[user.userId] = userDict
                        usersDict[contact.userId] = contactDict
                        
                        convDict["users"] = usersDict
                        
                        self.ref.child("conversations/\(uid)")
                            .setValue(convDict)
                    }
                }, withCancel: { (error) in
                    // Ignore
                })
            
            return Disposables.create()
        }
    }
    
    func loadMessages(of user: User, with contact: Contact) -> Observable<[Message]> {
        let uid = [user.userId, contact.userId].sorted()
            .joined(separator: " ")
        
        return createConversationIfNotExist(of: user, with: contact)
            .flatMap { [unowned self] (_) in
                return self.loadMessages(of: uid)
        }
    }
    

    func loadChatHistory(of user: User) -> Observable<[Conversation]> {
        return Observable.create { [unowned self] (obs) in
            let dbRequest = self.ref.child("conversations")
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
        
        guard let lastMessage = dict["last-message"] as? [String : Any] else {
            return nil
        }
        
        guard let usersDict = dict["users"] as? [String: Any] else {
            return nil
        }

        let convId = snapshot.key

        guard let isPrivate = dict["is-private"] as? Bool else {
            return nil
        }
        
        let displayAva = dict["display-ava"] as? String

        let nickname = parseNicknames(from: usersDict)

        guard let message = parseMessage(from: lastMessage) else {
            return nil
        }
        
        let type: ConvoType = isPrivate ? .single : .group
        let res = Conversation(
            id: convId,
            type: type,
            lastMess: message,
            nickname: nickname,
            displayAva: displayAva)
        return res
    }
    
    private func parseNicknames(from userDict: [String: Any]) -> [String: String] {
        var res = [String: String]()
        for (key, value) in userDict {
            res[key] = (value as! [String : Any])["nickname"] as? String ?? key
        }
        return res
    }
    
    private func parseMessage(from messageDict: [String : Any]) -> Message? {
        let type = (messageDict["type"] as! String).map { (it) -> MessageType in
            return .text
        }[0]
        
        var data = [String : String]()
        data["content"] = messageDict["content"] as? String
        data["at-time"] = messageDict["at-time"] as? String
        data["sent-by"] = messageDict["sent-by"] as? String
        
        return Message(type: type, data: data)
    }

    func sendMessage(message: Message, from user: User, to contact: Contact) -> Observable<Bool> {
        let uid = [user.userId, contact.userId].sorted()
            .joined(separator: " ")
        return self.sendMessage(message: message, to: uid)
    }
    
    func sendMessage(message: Message, to conversation: String) -> Observable<Bool> {
        let jsonMessage = self.mapToJson(message: message)
        self.ref.child("conversations/\(conversation)/last-message")
            .setValue(jsonMessage)
        self.ref.child("messages/\(conversation)")
            .childByAutoId()
            .setValue(jsonMessage)
        return Observable.just(true)
    }
    
    private func mapToJson(message: Message) -> [String : Any] {
        var res = [String : String]()
        res["at-time"] = message.data["at-time"]
        res["sent-by"] = message.data["sent-by"]
        res["type"] = message.data["type"]
        res["content"] = message.data["content"]
        return res
    }
}
