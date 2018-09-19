import RxSwift
import FirebaseDatabase
import FirebaseStorage

class ConversationFirebaseSource: ConversationRemoteSource {

    
    var ref: DatabaseReference!
    private var currentConversationId: String?
    
    init() {
        ref = Database.database().reference()
    }
    
    func getContactNickname(user: User, contact: Contact) -> Observable<String> {
        let uid = [user.userId, contact.userId].sorted()
            .joined(separator: " ")
        
        return Observable.create { [unowned self] (obs) in
            self.ref.child("conversations/\(uid)/users/\(contact.userId)/nickname")
                .observeSingleEvent(of: .value, with: { (snap) in
                    guard snap.exists() else {
                        obs.onNext(contact.userName)
                        return
                    }
                    
                    let nickname = snap.value as! String
                    obs.onNext(nickname)
                }, withCancel: { (e) in
                    obs.onError(e)
                })
            
            return Disposables.create()
        }
    }
    
    func observeNextMessage(fromLastId lastId: String?) -> Observable<Message> {
        return Observable.create { [unowned self] (obs) in
            guard let conversationId = self.currentConversationId else {
                // Break
                return Disposables.create()
            }
            
            let dbRequest = self.ref.child("messages/\(conversationId)")
                .queryOrderedByKey()
                .queryStarting(atValue: lastId)
                .queryLimited(toLast: 1)
                .observe(.childAdded, with: { (snap) in
                    // obs.onNext
                    guard snap.exists() else {
                        print("Snapshot not exist?")
                        return
                    }
                    
                    guard let messageDict = snap.value as? [String: Any] else {
                        return
                    }
                    
                    let message = self.parseMessage(
                        from: messageDict,
                        withMessId: snap.key)
                    if message != nil {
                        obs.onNext(message!)
                    }
                    
                }, withCancel: { (error) in
                    // obs.onError
                    obs.onError(error)
                })
            
            return Disposables.create { [unowned self] in
                self.ref.child("messages/\(conversationId)")
                    .removeObserver(withHandle: dbRequest)
            }
        }
    }
    
    func loadMessages(of conversationId: String) -> Observable<[Message]> {
        self.currentConversationId = conversationId
        return Observable.create { [unowned self] (observer) in
            let dbRequest = self.ref
                .child("messages/\(conversationId)")
                .queryOrderedByKey()
                // .queryLimited(toLast: 10)
                .observe(.value, with: { [unowned self] (snapshot) in
                    
                    // Iterate over the messages
                    guard snapshot.exists() else {
                        observer.onNext([])
                        observer.onCompleted()
                        return
                    }

                    var messages: [Message] = []
                    let ite = snapshot.children
                    while let snap = ite.nextObject() as? DataSnapshot {
                        guard let messageDict = snap.value as? [String: Any] else {
                            continue
                        }
                        
                        let message = self.parseMessage(
                            from: messageDict,
                            withMessId: snap.key)
                        if message != nil {
                            messages.insert(message!, at: 0)
                        }
                    }

                    observer.onNext(messages)
                    observer.onCompleted()
                }, withCancel: { (error) in
                    observer.onError(error)
                })
            
            
            return Disposables.create {
                self.currentConversationId = nil
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
                    
                    obs.onNext(true)
                    obs.onCompleted()
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
            .flatMap { [unowned self] (_) -> Observable<[Message]> in
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
                        
                        let item = self.parseConversation(from: dict, myId: user.userId)
                        
                        if item != nil {
                            items.append(item!)
                        }
                    }
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

    private func parseConversation(from snapshot: DataSnapshot, myId: String) -> Conversation? {
        
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
        let fromMe = message.data["sent-by"]!.elementsEqual(myId)
        let res = Conversation(
            id: convId,
            type: type,
            lastMess: message,
            nickname: nickname,
            displayAva: displayAva,
            fromMe: fromMe,
            myId: myId)
        return res
    }
    
    private func parseNicknames(from userDict: [String: Any]) -> [String: String] {
        var res = [String: String]()
        for (key, value) in userDict {
            res[key] = (value as! [String : Any])["nickname"] as? String ?? key
        }
        return res
    }
    
    private func parseMessage(from messageDict: [String : Any], withMessId: String? = nil) -> Message? {
        let type: MessageType
        guard let typeString = messageDict["type"] as? String else {
            return nil
        }
        if typeString.elementsEqual("text") {
            type = .text
        } else {
            type = .image
        }
        

        var data = [String : String]()
        data["content"] = messageDict["content"] as? String
        data["at-time"] = "\(messageDict["at-time"]!)"
        data["sent-by"] = messageDict["sent-by"] as? String
        
        if withMessId != nil {
            data["mess-id"] = withMessId!
        }
        
        return Message(type: type, data: data)
    }

    func sendMessage(message: Message, from user: User, to contact: Contact) -> Observable<Bool> {
        let uid = [user.userId, contact.userId].sorted()
            .joined(separator: " ")
        return self.sendMessage(message: message, to: uid)
    }
    
    func sendMessage(message: Message, to conversation: String) -> Observable<Bool> {
        if message.data["type"]!.elementsEqual("image") {
            return sendImageMessage(message: message, to: conversation)
        }
        
        let jsonMessage = self.mapToJson(message: message)
        self.ref.child("conversations/\(conversation)/last-message")
            .setValue(jsonMessage)
        self.ref.child("messages/\(conversation)")
            .childByAutoId()
            .setValue(jsonMessage)
        return Observable.just(true)
    }
    
    private func sendImageMessage(message: Message, to conversation: String) -> Observable<Bool> {
        return Observable.create { [unowned self] obs in
            // Generate message id
            let messId = self.ref.child("messages/\(conversation)")
                .childByAutoId()
                .key
           
            let urlString = message.data["content"]!
            let url = URL(fileURLWithPath: urlString)
            // Upload to Firebase Storage
            let ref = Storage.storage().reference()
                .child("messages/\(messId)")

            _ = ref.putFile(from: url, metadata: nil) { metadata, error in
                if error != nil {
                    obs.onError(error!)
                } else {
                    obs.onNext(true)
                    
                    // Update Firebase database
                    var jsonMessage = self.mapToJson(message: message)
                    jsonMessage["content"] = ImageLoader.buildUrl(forMessageId: messId)
                    self.ref.child("conversations/\(conversation)/last-message")
                        .setValue(jsonMessage)
                    self.ref.child("messages/\(conversation)")
                        .child(messId)
                        .setValue(jsonMessage)
                }
            }

            return Disposables.create()
        }
    }
    
    private func mapToJson(message: Message) -> [String : Any] {
        var res = [String : Any]()
        res["at-time"] = ServerValue.timestamp()
        res["sent-by"] = message.data["sent-by"]
        res["type"] = message.data["type"]
        res["content"] = message.data["content"]
        return res
    }
}
