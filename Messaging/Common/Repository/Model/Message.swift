struct Message {
    let type: MessageType
    let data: [String : String]
    let isSending: Bool
    
    init(type: MessageType, data: [String: String], isSending: Bool = false) {
        self.type = type
        self.data = data
        self.isSending = isSending
    }
    
    init(type: MessageType, convId: String?, content: String, atTime: String,
         sentBy: String, messId: String?, isSending: Bool = false) {
        var data = [String : String]()
        data["conversation-id"] = convId
        data["content"] = content
        data["at-time"] = atTime
        data["sent-by"] = sentBy
        data["mess-id"] = messId
        
        self.isSending = isSending
        self.type = type
        self.data = data
    }
    
    func getAtTime() -> String {
        return self.data["at-time"]!
    }
    
    func getType() -> String {
        return self.data["type"]!
    }
    
    func getContent() -> String {
        return self.data["content"]!
    }
    
    func getSentBy() -> String {
        return self.data["sent-by"]!
    }
    
    func getMessageId() -> String {
        return self.data["mess-id"]!
    }
    
    func compareWith(_ m2: Message) -> Bool {
        return Int64(data["at-time"]!)! > Int64(m2.data["at-time"]!)!
    }
    
    func changeId(withServerId newId: String) -> Message {
        var data = self.data
        data["mess-id"] = newId
        return Message(type: self.type, data: data, isSending: self.isSending)
    }
    
    func markAsSending() -> Message {
        return Message(type: self.type, data: self.data, isSending: true)
    }
    
    func markAsSent() -> Message {
        return Message(type: self.type, data: self.data, isSending: false)
    }
}

enum MessageType {
    case text
    case image
}
