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
    
    func loadConversations(of user: User) -> Observable<[Conversation]> {
        return Observable.create { [unowned self] (observer) in
            
            let dbRequest = self.ref.child("chat-history/\(user.userId)")
                .observe(.value, with: { (snapshot) in
                    
                    guard snapshot.exists() else {
                        observer.onNext([])
                        return
                    }
                    
                    var conversationIds = [ConvoWrapper]()
                    if let historyDict = snapshot.value as? [String: String] {
                        historyDict.forEach { (key, value) in
                            conversationIds.append(ConvoWrapper(convoId: key, convoType: value))
                        }
                    }
                    
                    observer.onNext(conversationIds)
                }) { (error) in
                    observer.onError(error)
            }
            
            return Disposables.create { [unowned self] in
                self.ref.child("chat-history/\(user.userId)")
                    .removeObserver(withHandle: dbRequest)
            }
            }.flatMap { [unowned self] (convoIds) -> Observable<[Conversation]> in
                return self.loadConversationDetail(convoIds)
        }
        
    }
    
    private func loadConversationDetail(_ wrappers: [ConvoWrapper]) -> Observable<[Conversation]> {
        return Observable.create { [unowned self] (observer) in
            let dbRequest = self.ref.child("conversations")
                .observe(.value, with: { (snapshot) in
                    
                    var res = [Conversation]()
                    guard let snapshotDict = snapshot.value as? [String: Any] else {
                        observer.onNext([])
                        return
                    }
                    
                    for (key, value) in snapshotDict {
                        guard let indx = wrappers.index(where: { (wrapper) -> Bool in
                            return wrapper.convoId.elementsEqual(key)
                        }) else {
                            continue
                        }
                        
                        guard let bigDict = value as? [String : Any]  else {
                            continue
                        }
                        
                        guard let nicknameDict = bigDict["joined-by"]
                            as? [String: String] else {
                                continue
                        }
                        
                        guard let lastMessDict = bigDict["most-recent"]
                            as? [String : String] else {
                                continue
                        }
                        
                        let convoType: ConvoType
                        if wrappers[indx].convoType.elementsEqual("single") {
                            convoType = .single
                        } else {
                            convoType = .group
                        }
                        
                        let conv = Conversation(convoId: wrappers[indx].convoId,
                            convoType: convoType,
                            nicknameDict: nicknameDict,
                            lastMessDict: lastMessDict)
                        
                        res.append(conv)
                    }
                    
                    observer.onNext(res)
                    observer.onCompleted()
                }) { (error) in
                    
                    observer.onError(error)
            }
            
            return Disposables.create { [unowned self] in
                self.ref.child("conversation").removeObserver(withHandle: dbRequest)
            }
        }
    }

//    func loadMessage(withId messageId: String) -> Observable<Message> {
//
//    }
}

class ConvoWrapper {
    let convoId: String
    let convoType: String
 
    init(convoId: String, convoType: String) {
        self.convoId = convoId
        self.convoType = convoType
    }
}

