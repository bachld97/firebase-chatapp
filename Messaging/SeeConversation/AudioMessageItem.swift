
class AudioMessageItem : MessageItem {
    var isPlaying : Bool

    init(messageItemType: MessageItemType, message: Message,
         showTime: Bool = false, isPlaying: Bool = false) {
        self.isPlaying = isPlaying
        super.init(messageItemType: messageItemType,
                   message: message,
                   showTime: showTime)
    }
    
    override func showNoTime() -> MessageItem {
        return AudioMessageItem(
            messageItemType: self.messageItemType,
            message: self.message,
            showTime: false,
            isPlaying: self.isPlaying)
    }
    
    static func == (lhs: AudioMessageItem, rhs: MessageItem) -> Bool {
        return rhs is AudioMessageItem
            && rhs.message.getMessageId().elementsEqual(rhs.message.getMessageId())
            && lhs.isPlaying == (rhs as! AudioMessageItem).isPlaying
    }
}
