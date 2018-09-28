class ConversationItem : Hashable {
    var hashValue: Int {
        return conversation.id.hashValue
    }
    
    static func == (lhs: ConversationItem, rhs: ConversationItem) -> Bool {
        return lhs.conversation.id
            .elementsEqual(rhs.conversation.id)
    }
    
    let conversation: Conversation
    let convoType: ConvoType
    init(conversation: Conversation) {
        self.conversation = conversation
        self.convoType = conversation.type
    }
}
