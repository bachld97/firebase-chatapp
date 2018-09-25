import UIKit

final class MessageItem : Hashable {
    
    var hashValue: Int {
        return message.getMessageId().hashValue
    }
    
    static func == (lhs: MessageItem, rhs: MessageItem) -> Bool {
        return lhs.message.getMessageId()
            .elementsEqual(rhs.message.getMessageId())
    }
    
    let messageItemType: MessageItemType
    let message: Message
    
    
    init(messageItemType: MessageItemType, message: Message) {
        self.messageItemType = messageItemType
        self.message = message
    }
}

enum MessageItemType {
    case text
    case textMe
    case image
    case imageMe
}
