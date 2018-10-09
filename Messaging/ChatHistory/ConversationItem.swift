class ConversationItem : Hashable {
    var hashValue: Int {
        return conversation.id.hashValue
    }
    
    static func == (lhs: ConversationItem, rhs: ConversationItem) -> Bool {
        let t1 = lhs.conversation.lastMess.getAtTimeAsNum()
        let t2 = rhs.conversation.lastMess.getAtTimeAsNum()
        let change = abs(t1 - t2) > 200 || lhs.isMessageSeen != rhs.isMessageSeen
        return !change &&
            lhs.conversation.id.elementsEqual(rhs.conversation.id)
    }
    
    let conversation: Conversation
    let convoType: ConvoType
    let displayTime: String
    let displayTitle: String
    let displayContent: String
    let displayAva: String
    let isMessageSeen: Bool
    
    init(conversation: Conversation) {
        self.conversation = conversation
        self.convoType = conversation.type
        self.displayTime = Converter.convertToHistoryTime(timestamp: conversation.lastMess.getAtTimeAsNum())
        
        let tem = conversation.id.split(separator: " ")
        var userToDisplay: String!
        if tem[0].elementsEqual(conversation.myId) {
            userToDisplay = String(tem[1])
        } else {
            userToDisplay = String(tem[0])
        }
        self.displayAva = UrlBuilder.buildUrl(forUserId: userToDisplay)
        
        self.displayTitle = conversation.nickname[userToDisplay] ?? userToDisplay
        
        let content: String
        switch conversation.lastMess.type {
        case .text:
            content = conversation.lastMess.getContent()
        case.image:
            content = "[Image]"
        }
        
        self.displayContent = content
        
        self.isMessageSeen = conversation.lastSeen[conversation.myId] ?? -1 >= conversation.lastMess.atTimeAsNum
    }
}
