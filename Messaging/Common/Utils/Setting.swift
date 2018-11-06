import UIKit

class Setting {
    static let colorOther = UIColor(
        red: 137 / 255.0, green: 229 / 255.0,
        blue: 163 / 255.0, alpha: 1)
    
    static let colorThis = UIColor(
        red: 221.0 / 255.0, green: 234.0 / 255.0,
        blue: 1, alpha: 1)
    
    static let colorSending = UIColor(
        red: 221.0 / 255.0, green: 190.0 / 255.0,
        blue: 200 / 255.0, alpha: 1)
    
    static let colorFail = UIColor(
        red: 80.0 / 255.0, green: 80.0 / 255.0,
        blue: 200 / 255.0, alpha: 1)
    
    class func getCellColor(for senderType: SenderType) -> UIColor {
        return senderType == .currentUser ? colorThis : colorOther
    }
    
    class func getCellColor(forState messageState: MessageState) -> UIColor {
        return messageState == .isSending ? colorSending : colorFail
    }
}

enum MessageState {
    case isSending
    case isFail
}

enum SenderType {
    case currentUser
    case otherUser
}
