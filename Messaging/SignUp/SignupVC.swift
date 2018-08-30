import RxSwift
import RxCocoa
import UIKit

class SignupVC : BaseVC, ViewFor {
    class func instance() -> UIViewController {
        return SignupVC()
    }
    
    public typealias ViewModelType = SignupViewModel
    public var viewModel: SignupViewModel!
    
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var fullnameTF: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.viewModel = SignupViewModel(displayLogic: self)
    }
    
    init() {
        super.init(nibName: "SignupVC", bundle: nil)
        self.viewModel = SignupViewModel(displayLogic: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Signup"
    }
    
    override func bindViewModel() {
        let input = SignupViewModel.Input(
            signupTrigger: signupButton.rx.tap.asDriver(),
            username: usernameTF.rx.text.orEmpty,
            password: passwordTF.rx.text.orEmpty,
            confirmPassword: confirmPasswordTF.rx.text.orEmpty,
            fullname: fullnameTF.rx.text.orEmpty)
        
        let output = viewModel.transform(input: input)
        
        output.error.drive(onNext: { [unowned self] (error) in
            self.handleError(e: error)
        }).disposed(by: self.disposeBag)
    }
}

extension SignupVC : SignupDisplayLogic {
    func goMain() {
        let vc = MainVC.instance()
        self.navigationController?.setViewControllers([vc], animated: true)
    }
    
    func hideKeyboard() {
        self.view.resignFirstResponder()
    }
}
