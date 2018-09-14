import UIKit
import RxCocoa
import RxSwift

class RequestingContactCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    
    private var contactItem: ContactItem?
    private var disposeBag = DisposeBag()
    private var imageTask: URLSessionTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }

    func bind(item: ContactItem, cancelRequest: PublishSubject<ContactItem>) {
        self.contactItem = item
        
        nameLabel.text = item.contact.userName
        idLabel.text = item.contact.userId
        let avaUrl = ImageLoader.buildUrl(forUserId: item.contact.userId)
        
        imageTask?.cancel()
        imageTask = ImageLoader.load(urlString: avaUrl, into: self.avaImageView)
        
        cancelButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                if self.contactItem != nil {
                    cancelRequest.onNext(self.contactItem!)
                }
            })
            .disposed(by: self.disposeBag)
    }
}
