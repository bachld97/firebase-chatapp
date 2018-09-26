class MessasgeItemDataSource : BaseDatasource<BaseMessageCell, MessageItem> {
    
    private let configureCell = { (cell: BaseMessageCell, item: MessageItem) -> BaseMessageCell in
        cell.item = item
        return cell
    }
    
    private let getReuseIdentifier = { (item: MessageItem) -> String in
        switch item.messageItemType {
        case .text:
            return item.showTime ? TextTimeMessageCell.reuseIdentifier : TextMessageCell.reuseIdentifier
        case .textMe:
            return item.showTime ? TextMeTimeMessageCell.reuseIdentifier : TextMeMessageCell.reuseIdentifier
        case .image:
            return item.showTime ? ImageTimeMessageCell.reuseIdentifier : ImageMessageCell.reuseIdentifier
        case .imageMe:
            return item.showTime ? ImageMeTimeMessageCell.reuseIdentifier : ImageMeMessageCell.reuseIdentifier
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
            if change {
                items[1] = items[1].showNoTime()
            }
            return (true, change ? 1 : 0)
        }
    }
}
