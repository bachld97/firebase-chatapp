import UIKit
import RxCocoa
import RxSwift

class RequestedContactCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var avaImageView: UIImageView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    private var contactItem: ContactItem?
    private var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }

    func bind(item: ContactItem, acceptRequest: PublishSubject<ContactItem>, cancelRequest: PublishSubject<ContactItem>) {
        nameLabel.text = item.contact.userName
        idLabel.text = item.contact.userId
        let avaUrl = item.contact.userAvatarUrl
        if avaUrl != nil {
            ImageLoader.load(urlString: avaUrl!, into: self.avaImageView)
        }
        
        acceptButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                if self.contactItem != nil {
                    acceptRequest.onNext(self.contactItem!)
                }
            })
            .disposed(by: self.disposeBag)
        
        cancelButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                if self.contactItem != nil {
                    cancelRequest.onNext(self.contactItem!)
                }
            })
            .disposed(by: self.disposeBag)
    }
}
