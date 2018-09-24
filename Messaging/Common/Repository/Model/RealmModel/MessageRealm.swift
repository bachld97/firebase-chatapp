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
        messageRealm.messageId = message.data["mess-id"] ?? message.data["local-id"]!
        messageRealm.sentBy = message.data["sent-by"]!
        messageRealm.content = message.data["content"]!
        messageRealm.atTime = Int64(message.data["at-time"]!)!
        messageRealm.conversationId = conversationId
        messageRealm.type = typeToTextMap[message.type]!
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
        let type: MessageType = MessageRealm.textToTypeMap[self.type]!
        return Message(type: type, data: data, isSending: isSending)
    }
    
    private static let typeToTextMap: [MessageType : String] = [
        MessageType.image : "image",
        MessageType.text : "text"
    ]
    
    private static let textToTypeMap: [String : MessageType] = [
        "image" : MessageType.image,
        "text" : MessageType.text
    ]
}
