import Foundation

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
        case .video:
            content = "[Video file]"
        case.audio:
            content = "[Audio file]"
        case .text:
            // Compute attributed text
            let htmlData = NSString(string: conversation.lastMess.getContent())
                .data(using: String.Encoding.unicode.rawValue)
            let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
            let attrText = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
            
            content = attrText.string
        case.image:
            content = "[Image]"
        case .contact:
            content = "[Contact]"
        case .location:
            content = "[Location]"
        case .file:
            let c = conversation.lastMess.getContent()
            let fileName: String
            if c.contains(" ") {
                fileName = String(c.split(separator: " ").last!)
            } else {
                fileName = c
            }
            content = "[File] \(fileName)"
        }
        
        self.displayContent = content
        
        self.isMessageSeen = conversation.lastSeen[conversation.myId] ?? -1 >= conversation.lastMess.atTimeAsNum
    }
}
