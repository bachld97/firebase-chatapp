import DeepDiff
import RxSwift

class MessasgeItemDataSource : BaseDatasource<BaseMessageCell, MessageItem> {
    
//    private let resendPublish: PublishSubject<MessageItem>
    
    private let configureCell: (BaseMessageCell, MessageItem) -> BaseMessageCell
    
    private let getReuseIdentifier = { (item: MessageItem) -> String in
        switch item.messageItemType {
        case .contact:
            return item.showTime ? ContactTimeMessageCell.reuseIdentifier : ContactMessageCell.reuseIdentifier
        case .contactMe:
            return item.showTime ? ContactMeTimeMessageCell.reuseIdentifier : ContactMeMessageCell.reuseIdentifier
        case .text:
            return item.showTime ? TextTimeMessageCell.reuseIdentifier : TextMessageCell.reuseIdentifier
        case .textMe:
            return item.showTime ? TextMeTimeMessageCell.reuseIdentifier : TextMeMessageCell.reuseIdentifier
        case .image:
            return item.showTime ? ImageTimeMessageCell.reuseIdentifier : ImageMessageCell.reuseIdentifier
        case .imageMe:
            return item.showTime ? ImageMeTimeMessageCell.reuseIdentifier : ImageMeMessageCell.reuseIdentifier
        case .location:
            return item.showTime ? LocationTimeMessageCell.reuseIdentifier : LocationMessageCell.reuseIdentifier
        case .locationMe:
            // Use this as a placeholder to displace lat/long to debug
            return item.showTime ? LocationMeTimeMessageCell.reuseIdentifier : LocationMeMessageCell.reuseIdentifier
        }
    }
    
    init(_ resendPublish: PublishSubject<MessageItem>,
         _ clickPublish: PublishSubject<MessageItem>) {
//        self.resendPublish = resendPublish
//        self.
        self.configureCell = { (cell: BaseMessageCell, item: MessageItem) -> BaseMessageCell in
            cell.messagePublish = resendPublish
            cell.clickPublish = clickPublish
            cell.item = item
            return cell
        }
        
        super.init(items: [], configureCell: self.configureCell,
                   getReuseIdentifier: self.getReuseIdentifier)
    }
    
    func setItems(items: [MessageItem]) -> [Change<MessageItem>]? {
        if items.count == 0 && self.items.count == 0 {
            return nil
        }
        
        let changes = diff(old: self.items, new: items)
        self.items = items
        return changes
    }
    
    
    // Returns if it is an insert
    func addOrUpdateSingleItem(item: MessageItem) -> (Bool, Int) {
        let index = items.firstIndex(of: item)
        if index != nil {
            let showTime = index! == 0 ||
                !items[index! - 1].message.getSentBy().elementsEqual(item.message.getSentBy())
            if !showTime {
                super.updateItem(at: index!, with: item.showNoTime())
            } else {
                super.updateItem(at: index!, with: item)
            }
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
