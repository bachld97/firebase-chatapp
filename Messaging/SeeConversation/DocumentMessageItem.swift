
class DocumentMessageItem : MessageItem {
    var isDocumentDownloaded: Bool = false
    
    init(messageItemType: MessageItemType, message: Message, isDocumentDownloaded: Bool,
         showTime: Bool = false) {
        self.isDocumentDownloaded = isDocumentDownloaded
        super.init(messageItemType: messageItemType, message: message, showTime: showTime)
    }
    
    static func == (lhs: DocumentMessageItem, rhs: MessageItem) -> Bool {
        return rhs is DocumentMessageItem
            && lhs.message.getMessageId().elementsEqual(rhs.message.getMessageId())
            && lhs.isDocumentDownloaded == (rhs as! DocumentMessageItem).isDocumentDownloaded
    }
    
    override func showNoTime() -> MessageItem {
        return DocumentMessageItem(
            messageItemType: self.messageItemType,
            message: self.message,
            isDocumentDownloaded: self.isDocumentDownloaded,
            showTime: false
        )
    }
}
