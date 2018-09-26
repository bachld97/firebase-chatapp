class MessasgeItemDataSource : BaseDatasource<BaseMessageCell, MessageItem> {
    
    private let configureCell = { (cell: BaseMessageCell, item: MessageItem) -> BaseMessageCell in
        cell.item = item
        return cell
    }
    
    private let getReuseIdentifier = { (item: MessageItem) -> String in
        switch item.messageItemType {
        case .text:
            return TextMessageCell.reuseIdentifier
        case .textMe:
            return TextMeMessageCell.reuseIdentifier
        case .image:
            return ImageMessageCell.reuseIdentifier
        case .imageMe:
            return ImageMeMessageCell.reuseIdentifier
        }
    }
    
    init() {
        super.init(items: [], configureCell: self.configureCell,
                   getReuseIdentifier: self.getReuseIdentifier)
    }
    
    
    // Returns if it is an insert
    func addOrUpdateSingleItem(item: MessageItem) -> (Bool, Int) {
        let index = items.firstIndex(of: item)
        if index != nil {
            super.updateItem(at: index!, with: item)
            return (false, index!)
        } else {
            super.insertItemAtFront(item)
            let change = items.count > 1 &&
                items[1].message.getSentBy().elementsEqual(item.message.getSentBy())
            return (true, change ? 1 : 0)
        }
    }
}
