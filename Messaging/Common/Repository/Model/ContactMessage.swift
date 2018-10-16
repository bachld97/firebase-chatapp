
class ContactMessage : Message {
    let contact: Contact
    let user: User
    
    init(contact: Contact, user: User, atTime: String, isSending: Bool = false,
         isFail: Bool = false) {
        self.contact = contact
        self.user = user
        
        super.init(type: .contact, convId: nil, content: contact.userId,
                   atTime: atTime, sentBy: user.userId,
                   messId: "", isSending: isSending, isFail: isFail)
    }
    
    
    private init(contact: Contact, user: User, atTime: String, isSending: Bool = false,
                 isFail: Bool = false, messId: String, conId: String? = nil) {
        self.contact = contact
        self.user = user
        
        super.init(type: .contact, convId: conId, content: contact.userId,
                   atTime: atTime, sentBy: user.userId,
                   messId: messId, isSending: isSending, isFail: isFail)
    }
    
    override func changeId(withServerId newId: String, withConvId: String? = nil) -> Message {
        return ContactMessage(contact: contact, user: user,
                              atTime: self.getAtTime(), isSending: self.isSending,
                              isFail: self.isFail, messId: newId, conId: withConvId)
    }
    
    override func markAsSending() -> Message {
        return ContactMessage(contact: contact, user: user,
                              atTime: getAtTime(),
                              isSending: true, isFail: false,
                              messId: getMessageId(), conId: getConversationId())
    }
    
    override func markAsFail() -> Message {
        return ContactMessage(contact: contact, user: user,
                              atTime: getAtTime(),
                              isSending: false, isFail: true,
                              messId: getMessageId(), conId: getConversationId())
    }
    
    override func markAsSuccess() -> Message {
        return ContactMessage(contact: contact, user: user,
                              atTime: getAtTime(),
                              isSending: false, isFail: false,
                              messId: getMessageId(), conId: getConversationId())
    }
}
