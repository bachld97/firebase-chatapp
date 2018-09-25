import RxSwift
import FirebaseDatabase
import FirebaseStorage

class ConversationFirebaseSource2: ConversationRemoteSource {
    
    
    var ref: DatabaseReference!
    
    private var currentConversationId: String?
    private var pendingMessages: [Message] = []
    private var messagePublisher = PublishSubject<Message>()
    private var errorPublisher = PublishSubject<Error>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        ref = Database.database().reference()
    }
    
    // MARK: Public
    func loadChatHistory(of user: User) -> Observable<[Conversation]> {
        // This function currently doing client-side filter, which is inefficient
        
        return Observable.create { [unowned self] (obs) in
            let dbRequest = self.ref.child("conversations")
                .queryOrdered(byChild: "users/\(user.userId)/avail")
                .queryEqual(toValue: true)
                .observe(.value, with: { (snapshot) in
                    guard snapshot.exists() else {
                        obs.onNext([])
                        return
                    }
                    
                    var cons = [Conversation]()
                    for v in snapshot.children {
                        guard let dict = v as? DataSnapshot else {
                            continue
                        }
                        
                        let con = self.parseConversation(from: dict, myId: user.userId)
                        
                        if con != nil {
                            cons.append(con!)
                        }
                    }
                    
                    obs.onNext(cons)
                }, withCancel: { (error) in
                    obs.onError(error)
                })
            
            return Disposables.create {
                self.ref.child("conversations")
                    .removeObserver(withHandle: dbRequest)
            }
        }
    }
    
    func observeNextMessage(for user: User, fromLastId lastId: String?) -> Observable<Message> {
        return Observable.create { [unowned self] (obs) in
            guard let conversationId = self.currentConversationId else {
                return Disposables.create()
            }
            
            let messageRef = self.ref.child("messages/\(conversationId)")
            let query = messageRef.queryOrderedByKey()
            
            if lastId != nil {
                query.queryStarting(atValue: lastId)
            }
            
            let obsHandle = query.queryLimited(toLast: 1)
                .observe(.childAdded, with: { (snap) in
                    if lastId == nil {
                        self.handleSnapshot(snap, user, conversationId)
                    } else {
                        self.handleSnapshot(snap, user, conversationId, excluding: lastId!)
                    }
                }, withCancel: { (error) in
                    obs.onError(error)
                })
            
            let disposable = self.messagePublisher.asDriverOnErrorJustComplete()
                .drive(onNext: { (message) in
                    obs.onNext(message)
                })
            
            
            return Disposables.create { [unowned self] in
                messageRef.removeObserver(withHandle: obsHandle)
                disposable.dispose()
                self.emptyPending()
            }
        }
    }
    
    func sendMessage(message: Message, from user: User, to contact: Contact) -> Observable<Bool> {
        let convId = ConvId.get(for: user, with: contact)
        return self.sendMessage(message: message, to: convId)
    }
    
    func sendMessage(message: Message, to conversation: String) -> Observable<Bool> {
        if message.type == .image {
            return sendImageMessage(message: message, to: conversation)
        }
        
        return Observable.deferred { [unowned self] in
            let jsonMessage = self.mapToJson(message: message)
            
            self.ref.child("conversations/\(conversation)/last-message")
                .setValue(jsonMessage)
            
            self.ref.child("messages/\(conversation)")
                .childByAutoId()
                .setValue(jsonMessage, withCompletionBlock: { [unowned self] (error, dbRef) in
                    if error == nil {
                        self.handleSendSuccess(msgId: dbRef.key)
                    } else {
                        self.errorPublisher.onNext(error!)
                    }
                })
            
            return Observable.just(true)
        }
    }
    
    func loadMessages(of user: User, with contact: Contact) -> Observable<[Message]> {
        return self.createConversation(of: user, with: contact)
            .flatMap { [unowned self] (convId) -> Observable<[Message]> in
                return self.loadMessages(of: convId)
        }
    }
    
    func loadMessages(of conversationId: String) -> Observable<[Message]> {
        self.currentConversationId = conversationId
        return Observable.create { [unowned self] (obs) in
            let rqHandle = self.ref
                .child("messages/\(conversationId)")
                .queryOrderedByKey()
                .queryLimited(toLast: 20)
                .observe(.value, with: { [unowned self] (snap) in
                    guard snap.exists() else {
                        obs.onNext([])
                        obs.onCompleted()
                        return
                    }
                    
                    var messages: [Message] = []
                    let ite = snap.children
                    while let childSnap = ite.nextObject() as? DataSnapshot {
                        guard let messageDict = childSnap.value as? [String : Any] else {
                            continue
                        }
                        
                        let message = self.parseMessage(
                            from: messageDict,
                            withMessId: childSnap.key
                        )
                        
                        if message != nil {
                            messages.insert(message!, at: 0)
                        }
                    }
                    
                    obs.onNext(messages)
                    obs.onCompleted()
                    }, withCancel: { (error) in
                        obs.onError(error)
                })
            
            
            return Disposables.create {
                self.ref.child("messages/\(conversationId)")
                    .removeObserver(withHandle: rqHandle)
            }
        }
    }
    
    func getContactNickname(user: User, contact: Contact) -> Observable<String> {
        let convId = ConvId.get(for: user, with: contact)
        
        return Observable.create { [unowned self] (obs) in
            let nicknameRef = self.ref.child("conversations/\(convId)/users/\(contact.userId)/nickname")
            let handle = nicknameRef.observe(.value, with: { (snap) in
                guard snap.exists() else {
                    obs.onNext(contact.userName)
                    return
                }
                
                guard let nickname = snap.value as? String else {
                    obs.onNext(contact.userName)
                    return
                }
                
                obs.onNext(nickname)
            }, withCancel: { (e) in
                obs.onError(e)
            })
            
            return Disposables.create {
                nicknameRef.removeObserver(withHandle: handle)
            }
        }
    }
    
    
    // MARK: Private
    private func createConversation(of user: User, with contact: Contact) -> Observable<String> {
        return Observable.create { (obs) in
            let convId = ConvId.get(for: user, with: contact)
            
            let convRef = self.ref.child("conversations/\(convId)")
            let handle = convRef.observe(.value, with: {snapshot in
                if !snapshot.exists() {
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
                    
                    self.ref.child("conversations/\(convId)")
                        .setValue(convDict)
                }
                
                obs.onNext(convId)
                obs.onCompleted()
            }, withCancel: { (error) in
                obs.onError(error)
            })
            
            return Disposables.create {
                convRef.removeObserver(withHandle: handle)
            }
        }
    }
    
    private func parseConversation(from snapshot: DataSnapshot, myId: String) -> Conversation? {
        guard let dict = snapshot.value as? [String : Any] else {
            return nil
        }
        
        guard let lastMessage = dict["last-message"] as? [String : Any] else {
            return nil
        }
        
        guard let userDict = dict["users"] as? [String : Any] else {
            return nil
        }
        
        guard let isPrivate = dict["is-private"] as? Bool else {
            return nil
        }
        
        let displayAva = dict["display-ava"] as? String
        
        let nickname = parseNickname(from: userDict)
        
        guard let message = parseMessage(from: lastMessage) else {
            return nil
        }
        
        let convId = snapshot.key
        
        let type: ConvoType = isPrivate ? .single : .group
        let fromMe = message.getSentBy().elementsEqual(myId)
        return Conversation(
            id: convId,
            type: type,
            lastMess: message,
            nickname: nickname,
            displayAva: displayAva,
            fromMe: fromMe,
            myId: myId)
    }
    
    private func parseNickname(from userDict: [String : Any]) -> [String : String] {
        var res = [String : String]()
        for (key, value) in userDict {
            res[key] = (value as! [String : Any])["nickname"] as? String ?? key
        }
        return res
    }
    
    private func parseMessage(from messageDict: [String : Any], withMessId: String? = nil) -> Message? {
        guard let typeString = messageDict["type"] as? String else {
            return nil
        }
        
        let type = Type.getMessageType(fromString: typeString)
        var data = [String : String]()
        data["conversation-id"] = messageDict["conversation-id"] as? String
        data["content"] = messageDict["content"] as? String
        data["at-time"] = "\(messageDict["at-time"]!)"
        data["sent-by"] = messageDict["sent-by"] as? String
        data["local-id"] = messageDict["local-id"] as? String
        data["mess-id"] = withMessId
        
        
        return Message(type: type, data: data)
        
//        guard let convId = messageDict["conversation-id"] as? String else {
//            return nil
//        }
//        guard let content = messageDict["content"] as? String else {
//            return nil
//        }
//
//        let atTime = "\(messageDict["at-time"]!)"
//
//        guard let sentBy = messageDict["sent-by"] as? String else {
//            return nil
//        }
//
//        guard let localId = messageDict["local-id"] as? String else {
//            return nil
//        }
//
//        return Message(
//            type: type,
//            convId: convId,
//            content: content,
//            atTime: atTime,
//            sentBy: sentBy,
//            localId: localId,
//            messId: withMessId)
    }
    
    private func mapToJson(message: Message) -> [String : Any] {
        var res = [String : Any]()
        res["local-id"] = message.data["local-id"] // May not be needed anymore
        res["at-time"] = ServerValue.timestamp()
        res["sent-by"] = message.getSentBy()
        res["type"] = message.getType()
        res["content"] = message.getContent()
        return res
    }
    
    private func handleSnapshot(_ snap: DataSnapshot, _ user: User,
                                _ conversationId: String, excluding ignoreMessageWithId: String = "") {
        guard snap.exists() else {
            return
        }
        
        let messId = snap.key
        guard !messId.elementsEqual(ignoreMessageWithId) else {
            return
        }
        
        guard var messageDict = snap.value as? [String : Any] else {
            return
        }
        
        messageDict["conversation-id"] = conversationId
        let message = self.parseMessage(from: messageDict, withMessId: messId)
        
        guard message != nil else {
            return
        }
        
        let fromThis = message!.getMessageId().elementsEqual(user.userId)
        
        self.handleMessage(message!, fromThis: fromThis)
    }
    
    private func sendImageMessage(message: Message, to conversation: String) -> Observable<Bool> {
        return Observable.create { [unowned self] obs in
            let messId = self.ref.child("messages/\(conversation)")
                .childByAutoId()
                .key
            
            // TODO: publish this message to UI, using messId
            self.messagePublisher.onNext(message.changeId(withServerId: messId))
            
            let urlString = message.getContent()
            let url = URL(fileURLWithPath: urlString)
            
            let ref = Storage.storage().reference()
                .child("messages/\(messId)")
            
            _ = ref.putFile(from: url, metadata: nil) { metadata, error in
                if error != nil {
                    obs.onError(error!)
                } else {
                    var jsonMessage = self.mapToJson(message: message)
                    jsonMessage["content"] = ImageLoader.buildUrl(forMessageId: messId)
                    
                    
                    self.ref.child("conversations/\(conversation)/last-message")
                        .setValue(jsonMessage)
                    
                    self.ref.child("conversations/\(conversation)/last-message")
                        .child(messId)
                        .setValue(jsonMessage, withCompletionBlock: { [unowned self] (error, dbRef) in
                            if error != nil {
                                self.handleSendSuccess(msgId: dbRef.key)
                            } else {
                                self.errorPublisher.onNext(error!)
                            }
                        })
                    
                    obs.onNext(true)
                    obs.onCompleted()
                }
            }
            
            return Disposables.create()
        }
    }
    
    private func handleMessage(_ message: Message, fromThis: Bool) {
        if fromThis {
            handleMessageFromUser(message)
        } else {
            handleMessageFromOther(message)
        }
    }
    
    private func handleMessageFromUser(_ message: Message) {
        if !self.pendingContains(message) {
            self.pendingMessages.append(message)
            self.messagePublisher.onNext(message.markAsSending())
        } else {
            self.updatePending(message)
        }
    }
    
    private func handleMessageFromOther(_ message: Message) {
        self.messagePublisher.onNext(message)
    }
    
    private func pendingContains(_ message: Message) -> Bool {
        let index = self.pendingMessages.firstIndex(where: {
            $0.getMessageId().elementsEqual(message.getMessageId())
        })
        
        return index != nil
    }
    
    private func updatePending(_ message: Message) {
        let index = self.pendingMessages.firstIndex(where: {
            $0.getMessageId().elementsEqual(message.getMessageId())
        })
        
        if index != nil {
            self.pendingMessages[index!] = message
        }
    }
    
    private func emptyPending() {
        self.pendingMessages.removeAll()
    }
    
    private func getAndRemovePending(msgId: String) -> Message? {
        let index = self.pendingMessages.firstIndex(where: {
            $0.getMessageId().elementsEqual(msgId)
        })
        
        if index != nil {
            let msg = pendingMessages[index!]
            pendingMessages.remove(at: index!)
            return msg
        }
        
        return nil
    }
    
    private func handleSendSuccess(msgId: String) {
        let msg = self.getAndRemovePending(msgId: msgId)
        
        if msg != nil {
            self.messagePublisher.onNext(msg!)
        }
    }
}