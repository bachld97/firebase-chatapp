import RxSwift
import FirebaseDatabase
import FirebaseStorage

class ConversationFirebaseSource2: ConversationRemoteSource {

	var ref: DatabaseReference!

	private var currentConversationId: String?
	private var pendingMessages: [Message]
	private var messagePublisher = PublishSubject<Message>()
	private var errorPublisher = PublishSubject<Error>()

	private let disposeBag = DisposeBag()

	init() {
		ref = Database.database().reference()
	}

	// MARK: Public 
	func loadChatHistory(of user: User) -> Observable<[Conservation]> {
		return Observable.just([])
	}

	func observeNextMessage(for user: User, fromLastId lastId: String?) -> Observable<Message> {
		return Observable.create { [unowned self] (obs) in
			guard let conversationId = self.currentConversationId else {
				return Disposables.create()
			}

			let messageRef = self.ref.child("messages/\("conversationId"))
			let query = messageRef.queryOrderedByKey()

			if lastId != nil {
				query.queryStarting(atValue: lastId)
			}

			let obsHandle = query.queryLimited(toLast: 1)
			.observe(.childAdded, with: { (snap) in 
					self.handleSnapshot(snap, user, conversationId)
				}, withCancel: { (error) in
					obs.onError(error)
				})

			let disposable = self.messagePublish.asDriverOnErrorJustComplete()
				.do(onNext: { (message) in 
					obs.onNext(message) 
				})


			return Disposable.create { [unowned self] in
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
			let jsonMsg = self.mapToJson(message: message)

			self.ref.child("conversations/\(conversation)/last-message")
				.setValue(jsonMessage)

			self.ref.child("messages/\(conversation)")
				.childByAutoId()
				.setValue(jsonMessage, withCompletionBlock: { (error, dbRef) in
					if error != nil {
						self.handleSendSuccess(msgId: dbRef.key)
					} else {
						errorPublisher.onNext(error!)
					}
				})

			return Observable.just()
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
			let rqHandler = self.ref
				.child("messages/\(conversationId))
				.queryOrderedByKey()
				.queryLimited(toLast: 20)
				.observe(.value, with: { [unowned self] (snap) in
					guard snap.exists() else {
						observer.onNext([])
						observer.onCompleted()
						return
					}

					var messages: [Message] = []
					let ite = snap.children
					while let childSnap = ite.nextObject as? DataSnapshot {
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

	func getContactNickName(user: User, contact: Contact) -> Observable<String> {

	}


	// MARK: Private
	private func createConversation(of: user, with: contact) -> Observable<String> {
		return Observable.just("")
	}

	private func parseMessage(
		from messageDict: [String : Any], 
		witMessId: String? = nil) -> Message? {
		guard let typeString = messageDict["type"] as? String else {
			return nil
		}

		let type = Type.getMessageType(fromString: typeString)

		guard let convId = messageDict["conversation-id"] as? String,
			let content = messageDict["content"] as? String,
			let atTime = "\(messageDict["at-time"]!)",
			let sentBy = messageDict["sent-by" as? String,
			let localId = messageDict["local-id"] as? String else {
				return nil
			}

		return Message(
			convId: convId,
			content: content,
			atTime: atTime,
			sentBy: sentBy,
			localId: localId,
			messId: withMessId
		)
	}


	private func handleSnapshot(_ snap: DataSnapshot, _ user: User, _ conversationId: String) {
		guard let snap.exists() else {
			return
		}

		let messId = snap.key
		guard var messageDict = snap.value as? [String : Any] else {
			return
		}

		messageDict["conversation-id"] = conversationId
		let message = self.parseMessage(from: messageDict, withMessId: messId)

		guard message != nil else {
			return
		}

		let fromThis = message!.getMessageId().elementEquals(user.userId) 

		self.handleMessage(message, fromThis: fromThis)
	}

	private func sendImageMessage(message: Message, to conversation: String) -> Observable<Bool> {
		// TODO: <++>
	}

	private func handleMessage(_ message: Message, fromThis: Bool) {
		// FromThis = true: If pending not have -> add + notifyNew
		// ---- else update
		// else notifyNew
	}

	private func emptyPending() {

	}

	private func handleSendSuccess(msgId: String) {

	}
}
