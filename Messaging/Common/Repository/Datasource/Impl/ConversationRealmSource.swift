import RealmSwift
import RxSwift

class ConversationRealmSource : ConversationLocalSource {
    
    func loadChatHistory(of user: User) -> Observable<[Conversation]> {
        return Observable.deferred { [unowned self] in
            let realm = try Realm()
            let conversations = realm.objects(ConversationRealm.self)
                .filter("userId == %@", user.userId)
                .compactMap({ [unowned self] in
                    return self.convertToConversation(realmConversation: $0,
                                                      userId: user.userId)
                })
            
            return Observable.just(Array(conversations))
        }
    }
    
    func persistConversations(_ conversations: [Conversation], of user: User) -> Observable<[Conversation]> {
        return Observable.deferred {
            let realm = try Realm()
            try conversations.forEach { (conv) in
                try realm.write {
                    realm.add(ConversationRealm.from(conv), update: true)
                }
            }
            return Observable.just(conversations)
        }
    }
    
    private func convertToConversation(realmConversation: ConversationRealm, userId: String) -> Conversation? {
        do {
            let realm = try Realm()
            let mess = realm.objects(MessageRealm.self)
                .filter("conversationId == %@", realmConversation.convId)
                .sorted(byKeyPath: "atTime")
                .first
            
            guard let unwrappedMess = mess?.convert() else {
                return nil
            }
            
            let fromMe = userId.elementsEqual(unwrappedMess.getSentBy())
            let type = realmConversation.isPrivate
                ? ConvoType.single : ConvoType.group
            let nicknames =
                DictionaryConverter.convert(from: realmConversation.nicknames)
            let displayAva: String? = nil
            
            return Conversation(id: realmConversation.convId, type: type, lastMess: unwrappedMess, nickname: nicknames, displayAva: displayAva, fromMe: fromMe, myId: userId)
        } catch {
            return nil
        }
    }
    
    
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
			try messages.forEach { (message) in 
				try realm.write {
					realm.add(MessageRealm.from(message, with: conversationId), update: true)
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
