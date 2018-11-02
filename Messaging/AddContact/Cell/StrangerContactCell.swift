import UIKit
import RxCocoa
import RxSwift

class StrangerContactCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var addFriendButton: UIButton!
    
    private var contactItem: ContactItem?
    private var disposeBag = DisposeBag()
    private var imageLoader = _ImageLoader()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }

    func bind(item: ContactItem, addRequest: PublishSubject<ContactItem>) {
        self.contactItem = item
        
        self.nameLabel.text = item.contact.userName
        self.idLabel.text = item.contact.userId
        let avaUrl = UrlBuilder.buildUrl(forUserId: item.contact.userId)

        imageLoader.loadImage(url: avaUrl, into: self.avaImageView)

        addFriendButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                if self.contactItem != nil {
                    addRequest.onNext(self.contactItem!)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
}
