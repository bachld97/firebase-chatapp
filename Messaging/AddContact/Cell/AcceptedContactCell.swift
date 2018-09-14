import UIKit
import RxSwift
import RxCocoa

class AcceptedContactCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var unfriendButton: UIButton!
    
    private var disposeBag = DisposeBag()
    private weak var contactItem: ContactItem?
    private var loadingImageTask: URLSessionTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    func bind(item: ContactItem, messageRequest: PublishSubject<ContactItem>, unfriendRequest: PublishSubject<ContactItem>) {
        self.contactItem = item
        nameLabel.text = item.contact.userName
        idLabel.text = item.contact.userId
        let avaUrl = ImageLoader.buildUrl(forUserId: item.contact.userId)
        
        loadingImageTask?.cancel()
        loadingImageTask = ImageLoader.load(urlString: avaUrl, into: self.avaImageView)

        messageButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                if self.contactItem != nil {
                    messageRequest.onNext(self.contactItem!)
                }
            })
            .disposed(by: self.disposeBag)
        
        unfriendButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                if self.contactItem != nil {
                    unfriendRequest.onNext(self.contactItem!)
                }
            })
            .disposed(by: self.disposeBag)
        
    }
}
