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
    
    init(messageItemType: MessageItemType, message: Message, showTime: Bool = false, displayTime: String? = nil) {
        self.messageItemType = messageItemType
        self.message = message
        if displayTime != nil {
            self.displayTime = displayTime!
        } else {
            self.displayTime = Converter.convertToMessageTime(timestamp: message.getAtTimeAsNum())
        }
        self.showTime = showTime
    }
    
    func showNoTime() -> MessageItem {
        return MessageItem(messageItemType: self.messageItemType,
                           message: self.message,
                           showTime: false,
                           displayTime: self.displayTime)
    }
}

enum MessageItemType {
    case text
    case textMe
    case image
    case imageMe
}
