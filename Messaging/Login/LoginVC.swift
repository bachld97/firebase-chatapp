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
        self.navigationItem.title = "Login"
        self.navigationController?.navigationBar.prefersLargeTitles = true

        let retryImg = UIImage(named: "ic_signup")?.withRenderingMode(.alwaysOriginal)
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

        let input = LoginViewModel.Input(
            trigger: viewWillAppear,
            signUpTrigger: self.navigationItem.rightBarButtonItem!.rx.tap.asDriver(),
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
        goToMainScreen()
    }
    
    func hideKeyboard() {
        self.view.resignFirstResponder()
    }
}

