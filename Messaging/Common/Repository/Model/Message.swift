struct Message {
    let type: MessageType
    let data: [String : String]
    let isSending: Bool
    
    init(type: MessageType, data: [String: String], isSending: Bool = false) {
        self.type = type
        self.data = data
        self.isSending = isSending
    }
    
//    Message(
//    convId: convId,
//    content: content,
//    atTime: atTime,
//    sentBy: sentBy,
//    localId: localId,
//    messId: withMessId)

    init(type: MessageType, convId: String, content: String, atTime: String,
         sentBy: String, localId: String, messId: String?, isSending: Bool = false) {
        var data = [String : String]()
        data["conversation-id"] = convId
        data["content"] = content
        data["at-time"] = atTime
        data["sent-by"] = sentBy
        data["local-id"] = localId
        data["mess-id"] = messId
        
        self.isSending = isSending
        self.type = type
        self.data = data
    }
    
    func getContent() -> String {
        return ""
    }
    
    func getSentBy() -> String {
        return ""
    }
    
    func getMessageId() -> String {
        return ""
    }
    
    func compareWith(_ m2: Message) -> Bool {
        return Int64(data["at-time"]!)! > Int64(m2.data["at-time"]!)!
    }
}

enum MessageType {
    case text
    case image
}
