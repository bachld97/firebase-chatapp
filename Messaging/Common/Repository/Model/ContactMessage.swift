
class ContactMessage : Message {
    let contact: Contact
    
    
    class func from(message: Message, contact: Contact) -> ContactMessage {
        return ContactMessage(contact: contact, senderId: message.getSentBy(),
                              atTime: message.getAtTime(),
                              isSending: message.isSending, isFail: message.isFail,
                              messId: message.getMessageId(), conId: message.conversationId)
    }
    
    
    init(contact: Contact, senderId: String, atTime: String, isSending: Bool = false,
         isFail: Bool = false) {
        self.contact = contact
        
        super.init(type: .contact, convId: nil, content: contact.userId,
                   atTime: atTime, sentBy: senderId,
                   messId: "", isSending: isSending, isFail: isFail)
    }
    
    private init(contact: Contact, senderId: String, atTime: String, isSending: Bool = false,
                 isFail: Bool = false, messId: String, conId: String? = nil) {
        self.contact = contact
        
        super.init(type: .contact, convId: conId, content: contact.userId,
                   atTime: atTime, sentBy: senderId,
                   messId: messId, isSending: isSending, isFail: isFail)
    }
    
    override func changeId(withServerId newId: String, withConvId: String? = nil) -> Message {
        return ContactMessage(contact: contact, senderId: getSentBy(),
                              atTime: self.getAtTime(), isSending: self.isSending,
                              isFail: self.isFail, messId: newId, conId: withConvId)
    }
    
    override func markAsSending() -> Message {
        return ContactMessage(contact: contact, senderId: getSentBy(),
                              atTime: getAtTime(),
                              isSending: true, isFail: false,
                              messId: getMessageId(), conId: getConversationId())
    }
    
    override func markAsFail() -> Message {
        return ContactMessage(contact: contact, senderId: getSentBy(),
                              atTime: getAtTime(),
                              isSending: false, isFail: true,
                              messId: getMessageId(), conId: getConversationId())
    }
    
    override func markAsSuccess() -> Message {
        return ContactMessage(contact: contact, senderId: getSentBy(),
                              atTime: getAtTime(),
                              isSending: false, isFail: false,
                              messId: getMessageId(), conId: getConversationId())
    }
}
