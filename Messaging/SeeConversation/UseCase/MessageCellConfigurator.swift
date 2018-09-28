import UIKit
import DeepDiff

class MessageCellConfigurator {
    private var strongDataSource: BaseDatasource<BaseMessageCell, MessageItem>?
    private weak var tableView: UITableView?
    
    
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
    
    var items: [MessageItem] = []
    
    func onNewSingleItem(_ item: MessageItem) {
        let index = items.index(where: { 
            return $0.message.getMessageId().elementsEqual(item.message.getMessageId())
        })
        
        if index != nil {
            // Re-evaluate a few things
            items[index!] = item
            strongDataSource?.updateItem(at: index!, with: item)
            let indexPath = NSIndexPath(row: index!, section: 0) as IndexPath
            self.tableView?.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        
        items.insert(item, at: 0)
        strongDataSource?.insertItemAtFront(item)
        let indexPath = NSIndexPath(row: 0, section: 0)
        self.tableView?.insertItemsAtIndexPaths([indexPath as IndexPath], animationStyle: .automatic)
    }
    
    func setItems(_ items: [MessageItem]) {
        if self.items.isEmpty && items.isEmpty {
            return
        }
        
        self.items = items
        self.strongDataSource?.updateItem(self.items)
        self.tableView?.reloadData()
    }
    
    init(tableView: UITableView) {
        self.tableView = tableView
        registerCells()
        self.strongDataSource = BaseDatasource(items: self.items, configureCell: self.configureCell, getReuseIdentifier: self.getReuseIdentifier)
        self.tableView?.dataSource = strongDataSource
    }
    
    private func registerCells() {
        self.tableView?.register(TextMessageCell.self)
        self.tableView?.register(TextMeMessageCell.self)
        self.tableView?.register(ImageMessageCell.self)
        self.tableView?.register(ImageMeMessageCell.self)
    }
}
