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
                .observe(.value, with: { [unowned self] (snapshot) in
                    
                    // Iterate over the messages
                    guard let bigDict = snapshot.value as? [String: Any] else {
                        observer.onNext([])
                        return
                    }
                    
                    var messages: [Message] = []
                    for (_, messValue) in bigDict {
                        guard let messageDict = messValue as? [String : String] else {
                            continue
                        }
                        
                        
                        let mess = self.parseMessage(from: messageDict)
                        if mess != nil {
                            messages.append(mess!)
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
        return Message()
    }

    func sendMessage(message: Message, from user: User, to contact: Contact) -> Observable<Bool> {
        return Observable.just(true)
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
        var res = [String : Any]()
        res["at-time"] = "123456"
        res["sent-by"] = "bachld10832"
        
        var data = [String: String]()
        data["type"] = "text"
        data["content"] = "Hello world"
        
        res["data"] = data
        return res
    }
}
