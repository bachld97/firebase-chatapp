//
//  ProfileViewController.swift
//  Messaging
import RxSwift
import UIKit

class SeeProfileVC : BaseVC , ViewFor {
    var viewModel: SeeProfileViewModel!
    private let disposeBag = DisposeBag()
    @IBOutlet weak var usernameLabel: UILabel!
    

    @IBOutlet weak var goChangePassButton: UIButton!
    typealias ViewModelType = SeeProfileViewModel
    
    
    class func instance() -> UIViewController {
        return SeeProfileVC()
    }
    
    init() {
        super.init(nibName: "SeeProfileVC", bundle: nil)
        self.viewModel = SeeProfileViewModel(displayLogic: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.viewModel = SeeProfileViewModel(displayLogic: self)
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Profile"
        
        
        let logOutImg = UIImage(named: "ic_logout")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: logOutImg,
                                                                 style: .plain,
                                                                 target: nil,
                                                                 action: nil)
        super.viewDidLoad()
    }
    
    override func bindViewModel() {
        let viewWillAppear = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = SeeProfileViewModel.Input(
            trigger: viewWillAppear,
            // reloadTrigger:,
            logoutTrigger: self.navigationItem.rightBarButtonItem!.rx.tap.asDriver(),
            changePassTrigger: goChangePassButton.rx.tap.asDriver())
        
        let output = viewModel.transform(input: input)
        
        output.error
            .do(onNext: { [unowned self] (error) in
                if error is SessionExpireError {
                    self.forceLogout()
                } else {
                    self.handleError(e: error)
                }
            })
            .drive()
            .disposed(by: self.disposeBag)
    }
    
}


extension SeeProfileVC : SeeProfileDisplayLogic {
    func goChangePass() {
        let vc = ChangePassVC.instance()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func forceLogout() {
        logoutWithSessionExpire()
    }
    
    func display(user: User) {
        self.usernameLabel.text = user.userName
    }
}
