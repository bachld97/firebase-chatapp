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
        switch item.messageType {
        case .text:
            return _TextMessageCell.reuseIdentifier
        case .textMe:
            return _TextMeMessageCell.reuseIdentifier
        case .image:
            return _ImageMessageCell.reuseIdentifier
        case .imageMe:
            return _ImageMeMessageCell.reuseIdentifier
        }
    }
    
    var items: [MessageItem] = []
    
    func onNewSingleItem(_ item: MessageItem) {
        // Assume we do not erase it
        let localId = item.messageData["local-id"] ?? "0"
        let id = item.messageData["mess-id"] ?? "0"
        
        let index = items.index(where: { (other) in
            let otherLocalId = other.messageData["local-id"] ?? "1"
            let otherId = other.messageData["mess-id"] ?? "1"
            
            return otherLocalId.elementsEqual(localId) ||
                otherId.elementsEqual(id)
        })
        
        if index != nil {
            // updates
            items[index!].isSending = false
            strongDataSource?.updateItem(at: index!, with: items[index!])
            let indexPath = NSIndexPath(row: index!, section: 0)
            self.tableView?.reloadItemsAtIndexPaths([indexPath as IndexPath], animationStyle: .automatic)
            return
        }
        
        items.insert(item, at: 0)
        strongDataSource?.insertItemAtFront(item)
        let indexPath = NSIndexPath(row: 0, section: 0)
        self.tableView?.insertItemsAtIndexPaths([indexPath as IndexPath], animationStyle: .automatic)
    }
    
    func setItems(_ items: [MessageItem]) {
        // let changes = diff(old: self.items, new: items)
        self.items = items
        self.strongDataSource?.updateItem(self.items)
        self.tableView?.reloadData()
//        self.tableView?.reload(changes: changes, completion: {_ in })
    }
    
    init(tableView: UITableView) {
        self.tableView = tableView
        registerCells()
        
        self.strongDataSource = BaseDatasource(items: self.items, configureCell: self.configureCell, getReuseIdentifier: self.getReuseIdentifier)
        self.tableView?.dataSource = strongDataSource
    }
    
    private func registerCells() {
        self.tableView?.register(_TextMessageCell.self)
        self.tableView?.register(_TextMeMessageCell.self)
        self.tableView?.register(_ImageMessageCell.self)
        self.tableView?.register(_ImageMeMessageCell.self)
    }
}
