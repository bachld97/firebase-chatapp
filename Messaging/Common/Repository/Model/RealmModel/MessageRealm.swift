import RealmSwift

class MessageRealm: Object {
    
    @objc dynamic var messageId: String = ""
    @objc dynamic var sentBy: String = ""
    @objc dynamic var atTime: Int64 = 0
    @objc dynamic var conversationId: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var content: String = ""
    @objc dynamic var isSending: Bool = false
    @objc dynamic var isFail: Bool = false
    
    override static func primaryKey() -> String? {
        return "messageId"
    }
    
    static func from(_ message: Message, with conversationId: String) -> MessageRealm {
        let messageRealm = MessageRealm()
        messageRealm.messageId = message.getMessageId()
        messageRealm.sentBy = message.getSentBy()
        messageRealm.content = message.getContent()
        messageRealm.atTime = Int64(message.getAtTime())!
        messageRealm.conversationId = conversationId
        messageRealm.type = Type.getMessageTypeString(fromType: message.type)
        messageRealm.isSending = message.isSending
        messageRealm.isFail = message.isFail
        return messageRealm
    }
    
    func convert() -> Message {
        let type: MessageType = Type.getMessageType(fromString: self.type)
        
        if type == .contact {
            var contactInfo = content.split(separator: "#")
                .map { String($0) }
            
            if contactInfo.isEmpty {
                contactInfo.append(content)
            }
            
            let contact = Contact(
                userId: contactInfo.first!,
                userName: contactInfo.last!,
                userAvatarUrl: nil)
            
            return ContactMessage(contact: contact, senderId: sentBy, atTime: "\(atTime)")
                .changeId(withServerId: messageId, withConvId: conversationId)
            
        } else {
            return Message(type: type, convId: self.conversationId, content: self.content, atTime: "\(self.atTime)",
                sentBy: self.sentBy, messId: self.messageId,
                isSending: self.isSending, isFail: self.isFail)
        }
    }
}
