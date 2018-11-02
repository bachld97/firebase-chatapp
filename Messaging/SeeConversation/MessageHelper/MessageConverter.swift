class MessageConverter {
    func convert(localMessage: Message) -> MessageItem {
        switch localMessage.type {
        case .audio:
            fatalError("Not implemented")
        case .file:
            let ext = String(localMessage.getContent().split(separator: ".").last!)
            let fileName = "\(localMessage.getMessageId()).\(ext)"
            let isDownloaded = FileUtil.fileExists(fileName)
            return DocumentMessageItem(messageItemType: .fileMe, message: localMessage, isDocumentDownloaded: isDownloaded)
        case .location:
            return MessageItem(messageItemType: .locationMe, message: localMessage)
        case .image:
            return MessageItem(messageItemType: .imageMe, message: localMessage)
        case .text:
            return MessageItem(messageItemType: .textMe, message: localMessage)
        case .contact:
            return MessageItem(messageItemType: .contactMe, message: localMessage)
        }
    }
    
    func convert(messages: [Message], user: User) -> [MessageItem] {
        var res: [MessageItem] = []
        for (index, m) in messages.enumerated() {
            let showTime = index == 0
                || !m.getSentBy().elementsEqual(messages[index - 1].getSentBy())
            
            switch m.type {
            case .audio:
                fatalError("Not implemented")
            case .file:
                let ext = String(m.getContent().split(separator: ".").last!)
                let fileName = "\(m.getMessageId()).\(ext)"
                let isDownloaded = FileUtil.fileExists(fileName)
                
                if m.getSentBy().elementsEqual(user.userId) {
                    res.append(DocumentMessageItem(
                        messageItemType: .fileMe, message: m,
                        isDocumentDownloaded: isDownloaded, showTime: showTime
                    ))
                    
                } else {
                    res.append(DocumentMessageItem(
                        messageItemType: .file, message: m,
                        isDocumentDownloaded: isDownloaded, showTime: showTime
                    ))
                }
            case .location:
                if m.getSentBy().elementsEqual(user.userId) {
                    res.append(MessageItem(messageItemType: .locationMe, message: m, showTime: showTime))
                } else {
                    res.append(MessageItem(messageItemType: .location, message: m, showTime: showTime))
                }
            case .image:
                if m.getSentBy().elementsEqual(user.userId) {
                    res.append(MessageItem(messageItemType: .imageMe, message: m, showTime: showTime))
                } else {
                    res.append(MessageItem(messageItemType: .image, message: m, showTime: showTime))
                }
                
            case .text:
                if m.getSentBy().elementsEqual(user.userId) {
                    res.append(MessageItem(messageItemType: .textMe, message: m, showTime: showTime))
                } else {
                    res.append(MessageItem(messageItemType: .text, message: m, showTime: showTime))
                }
            case .contact:
                if m.getSentBy().elementsEqual(user.userId) {
                    res.append(MessageItem(messageItemType: .contactMe, message: m, showTime: showTime))
                } else {
                    res.append(MessageItem(messageItemType: .contact, message: m, showTime: showTime))
                }
            }
        }
        
        return res
    }
}
