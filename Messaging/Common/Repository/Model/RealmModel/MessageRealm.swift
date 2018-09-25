import RealmSwift

class MessageRealm: Object {
    
    @objc dynamic var messageId: String = ""
    @objc dynamic var sentBy: String = ""
    @objc dynamic var atTime: Int64 = 0
    @objc dynamic var conversationId: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var content: String = ""
    @objc dynamic var isSending: Bool = false
    
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
        return messageRealm
    }
    
    func convert() -> Message {
        var data = [String : String]()
        data["mess-id"] = self.messageId
        data["sent-by"] = self.sentBy
        data["content"] = self.content
        data["at-time"] = "\(self.atTime)"
        let isSending = self.isSending
        let type: MessageType = Type.getMessageType(fromString: self.type)
        return Message(type: type, data: data, isSending: isSending)
    }
}
