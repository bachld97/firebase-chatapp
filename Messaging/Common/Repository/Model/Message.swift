class Message {
    let type: MessageType
    let isSending: Bool
    let isFail: Bool
    
    let conversationId: String?
    let content: String
    let atTime: String
    let atTimeAsNum: Int64
    let sentBy: String
    let messId: String?

    
    init(type: MessageType, convId: String?, content: String, atTime: String,
         sentBy: String, messId: String?, isSending: Bool = false, isFail: Bool = false) {
        self.isSending = isSending
        self.type = type
        self.conversationId = convId
        self.content = content
        self.atTime = atTime
        self.atTimeAsNum = Int64(atTime)!
        self.sentBy = sentBy
        self.messId = messId
        self.isFail = isFail
    }
    
    func compareWith(_ m2: Message) -> Bool {
        return self.getMessageId() > m2.getMessageId()
//        return self.getMessageId() > m2.getMessageId()
    }
    
    func getAtTime() -> String {
        return self.atTime
    }
    
    func getAtTimeAsNum() -> Int64 {
        return self.atTimeAsNum
    }
    
    func getTypeAsString() -> String {
        return Type.getMessageTypeString(fromType: self.type)
    }
    
    func getContent() -> String {
        return self.content
    }
    
    func getSentBy() -> String {
        return sentBy
    }
    
    func getMessageId() -> String {
        return messId!
    }
    
    func getConversationId() -> String? {
        return self.conversationId!
    }
    
    func changeId(withServerId newId: String, withConvId: String? = nil) -> Message {
        return Message(type: self.type,
                       convId: withConvId ?? self.getConversationId(),
                       content: self.getContent(),
                       atTime: self.getAtTime(),
                       sentBy: self.getSentBy(),
                       messId: newId,
                       isSending: self.isSending)
    }
    
    func changeContent(withNewContent newContent: String) -> Message {
        return Message(type: self.type,
                       convId: self.getConversationId(),
                       content: newContent,
                       atTime: self.getAtTime(),
                       sentBy: self.getSentBy(),
                       messId: self.getMessageId(),
                       isSending: self.isSending)
    }
    
    func markAsSending() -> Message {
        return Message(type: self.type,
                       convId: self.getConversationId(),
                       content: self.getContent(),
                       atTime: self.getAtTime(),
                       sentBy: self.getSentBy(),
                       messId: self.getMessageId(),
                       isSending: true, isFail: false)
    }
    
    func markAsFail() -> Message {
        return Message(type: self.type,
                       convId: self.getConversationId(),
                       content: self.getContent(),
                       atTime: self.getAtTime(),
                       sentBy: self.getSentBy(),
                       messId: self.getMessageId(),
                       isSending: false, isFail: true)
    }
    
    func markAsSuccess() -> Message {
        return Message(type: self.type,
                       convId: self.getConversationId(),
                       content: self.getContent(),
                       atTime: self.getAtTime(),
                       sentBy: self.getSentBy(),
                       messId: self.getMessageId(),
                       isSending: false, isFail: false)
    }
    
    
    func withSendingAndFailStatus(_ isSending: Bool, _ isFail: Bool) -> Message {
        return Message(type: self.type,
                       convId: self.getConversationId(),
                       content: self.getContent(),
                       atTime: self.getAtTime(),
                       sentBy: self.getSentBy(),
                       messId: self.getMessageId(),
                       isSending: isSending, isFail: isFail)
    }
}

enum MessageType {
    case text
    case image
    case contact
    case location
}
