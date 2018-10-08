import UIKit
import RxSwift

class BaseMessageCell: BaseCell<MessageItem> {
    
    open var messagePublish: PublishSubject<MessageItem>?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    func prepareUI() {}

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(:coder) is not implmented")
    }
}
