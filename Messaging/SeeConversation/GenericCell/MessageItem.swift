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
    
    let showTime: Bool
    
    let displayTime: String
    
    init(messageItemType: MessageItemType, message: Message, showTime: Bool = false) {
        self.messageItemType = messageItemType
        self.message = message
        self.displayTime = Converter.convertToLocalTime(timestamp: message.getAtTimeAsNum())
        self.showTime = showTime
    }
}

enum MessageItemType {
    case text
    case textMe
    case image
    case imageMe
}
