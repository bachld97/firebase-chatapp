import UIKit

final class MessageItem : Hashable {
    
    var hashValue: Int {
        return messageId.hashValue
    }
    
    static func == (lhs: MessageItem, rhs: MessageItem) -> Bool {
        return lhs.messageId.elementsEqual(rhs.messageId)
    }
    
    let messageType: _MessageType
    let messageId: String
    let messageData: [String: String]

    init(messageType: _MessageType, messageId: String, messageData: [String: String]) {
        self.messageType = messageType
        self.messageId = messageId
        self.messageData = messageData
    }
}

enum _MessageType {
    case text
    case textMe
    case image
    case imageMe
}
