import UIKit
import RxSwift
import RxCocoa

class LoginVC : BaseVC, ViewFor {
    class func instance() -> LoginVC {
        return LoginVC()
    }
    
    public typealias ViewModelType = LoginViewModel
    public var viewModel: LoginViewModel!
    
    // UI elements
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.viewModel = LoginViewModel(displayLogic: self)
    }
    
    init() {
        super.init(nibName: "LoginVC", bundle: nil)
        self.viewModel = LoginViewModel(displayLogic: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Login"
    }

    override func bindViewModel() {
        let viewWillAppear = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
                .mapToVoid()
                .asDriverOnErrorJustComplete()
        
        let input = LoginViewModel.Input(
            trigger: viewWillAppear,
            signUpTrigger: signupButton.rx.tap.asDriver(),
            loginTrigger: loginButton.rx.tap.asDriver(),
            username: usernameTF.rx.text.orEmpty,
            password: passwordTF.rx.text.orEmpty)
        
        let output = viewModel.transform(input: input)
        
        output.error.drive(onNext: { [unowned self] (error) in
            self.handleError(e: error)
        }).disposed(by: self.disposeBag)
    }
}

extension LoginVC : LoginDisplayLogic {
    func goSignup() {
        let vc = SignupVC.instance()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func goMain() {
        print("Go main called")
//        let vc = MainVC.instance()
        //        self.navigationController?.setViewControllers([vc], animated: true)
    }
    
    func hideKeyboard() {
        self.view.resignFirstResponder()
    }
}

