import Foundation

class MessageParser {
    private var lastMessTime: Int64 = 0
    private let thumbsUpText: String = "\(UnicodeScalar(0x1f44d)!)"
    
    func parseTextMessage(_ user: User, _ content: String) -> Message {
        return Message(type: .text,
                       convId: nil,
                       content: content,
                       atTime: self.getTime(),
                       sentBy: user.userId,
                       messId: nil)
    }
    
    func parseFileMessage(_ user: User, _ url: URL) -> Message {
        return Message(type: .file, convId: nil, content: url.path,
                       atTime: self.getTime(), sentBy: user.userId,
                       messId: url.lastPathComponent, isSending: true)
    }
    
    func parseImageMessage(_ user: User, _ url: URL) -> Message {
        return Message(type: .image, convId: nil, content: url.path,
                       atTime: self.getTime(), sentBy: user.userId,
                       messId: url.lastPathComponent, isSending: true)
    }
    
    func parseLocationMessage(_ user: User,
                                      _ lat: Double, _ long: Double) -> Message {
        return Message(type: .location,
                       convId: nil,
                       content: "\(lat)_\(long)",
            atTime: self.getTime(),
            sentBy: user.userId,
            messId: nil)
    }
    
    func createLikeMessage(_ user: User) -> Message {
        return Message(type: .text,
                       convId: nil,
                       content: self.thumbsUpText,
                       atTime: self.getTime(),
                       sentBy: user.userId,
                       messId: nil)
    }
    
    func parseContactMessage(_ user: User, _ contact: Contact) -> Message {
        
        return ContactMessage(contact: contact, senderId: user.userId, atTime: self.getTime(),
                              isSending: true)
    }
    
    func updateTime(_ item: MessageItem?) {
       let newTime = Int64(item?.message.getAtTime() ?? "\(self.lastMessTime)") ?? self.lastMessTime
        
        if newTime > lastMessTime {
            self.lastMessTime = newTime
        }
    }

    private func getTime() -> String {
        return "\(lastMessTime + 1)"
    }
}
