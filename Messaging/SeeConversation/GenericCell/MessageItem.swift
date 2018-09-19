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
    let isSending: Bool
    
    init(messageType: _MessageType, messageId: String,
         messageData: [String: String], isSending: Bool = false) {
        self.messageType = messageType
        self.messageId = messageId
        self.messageData = messageData
        self.isSending = isSending
    }
}

enum _MessageType {
    case text
    case textMe
    case image
    case imageMe
}
