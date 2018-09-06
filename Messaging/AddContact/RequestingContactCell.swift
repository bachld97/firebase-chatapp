import UIKit
import RxSwift

class RequestingContactCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func bind(item: ContactItem, cancelRequest: PublishSubject<ContactItem>) {
        nameLabel.text = item.contact.userName
        idLabel.text = item.contact.userId
        let avaUrl = item.contact.userAvatarUrl
        if avaUrl != nil {
            ImageLoader.load(urlString: avaUrl!, into: self.avaImageView)
        }
    }
}
