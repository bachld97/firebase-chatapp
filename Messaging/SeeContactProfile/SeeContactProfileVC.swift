import UIKit
import RxSwift
import RxCocoa

class SeeContactProfileVC : BaseVC, ViewFor {
    
    @IBOutlet weak var avaImage: UIImageView!
    
    @IBOutlet weak var contactName: UITextField!
    
    @IBOutlet weak var contactId: UITextField!
    
    @IBOutlet weak var sendMessageButton: UIButton!
    
    override func viewDidLoad() {
        avaImage.layer.cornerRadius = avaImage.frame.width / 2.0
        super.viewDidLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewModel: SeeContactProfileViewModel!
    typealias ViewModelType = SeeContactProfileViewModel
    
    private let imageLoader = _ImageLoader()
    private let disposeBag = DisposeBag()
    
    class func instance(userId: String) -> UIViewController {
        return SeeContactProfileVC(userId: userId)
    }

    init(userId: String) {
        super.init(nibName: "SeeContactProfileVC", bundle: nil)
        viewModel = SeeContactProfileViewModel(idToLoad: userId, displayLogic: self)
    }
    
    override func bindViewModel() {
        let viewWillAppear =
            self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
                .asDriverOnErrorJustComplete()
        
        let input = SeeContactProfileViewModel.Input(trigger: viewWillAppear)
        let output = self.viewModel.transform(input: input)
        output.error.drive(onNext: { [unowned self] (error) in
            self.handleError(e: error)
        }).disposed(by: self.disposeBag)
    }
    
}

extension SeeContactProfileVC : SeeContactProfileDisplayLogic {
    func displayContactDetails(contact: Contact) {
        self.contactName.text = contact.userName
        self.contactId.text = contact.userId
        let url = UrlBuilder.buildUrl(forUserId: contact.userId)
        self.imageLoader.loadImage(url: url, into: self.avaImage)
        
        
        sendMessageButton.rx.tap
            .asDriver()
            .drive(onNext: {
                let item = ContactItem(contact: contact)
                let vc = SeeConversationVC.instance(contactItem: item)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: self.disposeBag)
    }
}
