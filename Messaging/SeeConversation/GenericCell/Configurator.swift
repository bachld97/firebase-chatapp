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
    
    func setItems(_ items: [MessageItem]) {
        let changes = diff(old: self.items, new: items)
        self.items = items
        self.strongDataSource?.updateItem(self.items)
        self.tableView?.reload(changes: changes, completion: {_ in })
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

class ExampleVC : UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var configurator: MessageCellConfigurator?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configurator = MessageCellConfigurator(tableView: self.tableView)
    }
    
    func onNewData(items: [MessageItem]) {
        self.configurator?.setItems(items)
    }
}
