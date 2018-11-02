import UIKit

class BaseConversationCell: BaseCell<ConversationItem> {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    func prepareUI() {}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(:coder) is not implmented")
    }
}
