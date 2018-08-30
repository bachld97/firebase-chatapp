import UIKit
import RxSwift
import RxCocoa


class SeeContactVC: BaseVC, ViewFor {
    class func instance() -> UIViewController {
        return SeeContactVC()
    }
    
    public typealias ViewModelType = SeeContactViewModel
    var viewModel: SeeContactViewModel!
    private let disposeBag = DisposeBag()
    
    init() {
        super.init(nibName: "SeeContactVC", bundle: nil)
        self.viewModel = SeeContactViewModel(displayLogic: self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.viewModel = SeeContactViewModel(displayLogic: self)
    }

    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Contacts"
        
        let retryImg = UIImage(named: "ic_reload")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: retryImg,
                                                                 style: .plain,
                                                                 target: nil,
                                                                 action: nil)
        
        super.viewDidLoad()
    }
    
    override func bindViewModel() {
        let viewWillAppear = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = SeeContactViewModel.Input(
                trigger: viewWillAppear,
                reloadTrigger: self.navigationItem.rightBarButtonItem!.rx.tap.asDriver())
        
        
        
        let output = viewModel.transform(input: input)
        
        output.error.drive(onNext: { [unowned self] (error) in
            if error is SessionExpireError {
                self.forceLogout()
            } else {
                self.handleError(e: error)
            }
        }).disposed(by: self.disposeBag)
    }
}

extension SeeContactVC : SeeContactDisplayLogic {
    func goConversation() {
        let vc = SeeConversationVC.instance()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func displayContact(contacts: [Contact]?) {
        if contacts != nil {
            print("Contact loaded: \(contacts!.count)")
        }
    }
    
    func showEmpty() {
        print("Empty")
    }
    
    func forceLogout() {
        print("Session expired")
    }
}
