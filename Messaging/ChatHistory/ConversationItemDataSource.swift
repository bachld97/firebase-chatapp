import DeepDiff

class ConversationItemDataSource : BaseDatasource<BaseConversationCell, ConversationItem> {
    
    private let configureCell = { (cell: BaseConversationCell, item: ConversationItem) -> BaseConversationCell in
        cell.item = item
        return cell
    }
    
     private let getReuseIdentifier = { (item: ConversationItem) -> String in
        switch item.convoType {
            case .single:
                return PrivateConversationCell.reuseIdentifier
            case .group:
                return PrivateConversationCell.reuseIdentifier
        }
    }
    
    init() {
        super.init(items: [], configureCell: self.configureCell,
                   getReuseIdentifier: self.getReuseIdentifier)
    }
    
    func setItems(items: [ConversationItem]) -> [Change<ConversationItem>]? {
        if items.count == 0 && self.items.count == 0 {
            return nil
        }
        
        let changes = diff(old: self.items, new: items)
        self.items = items
        return changes
    }
    
    func getItem(atIndex index: Int) -> ConversationItem {
        return items[index]
    }
}
