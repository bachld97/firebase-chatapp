import UIKit
import RxSwift
import RxCocoa
import Toast

class ChangePassVC : BaseVC, ViewFor {
    var viewModel: ChangePassViewModel!
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var oldPasswordTF: UITextField!
    @IBOutlet weak var changePasswordButton: UIButton!
    
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var confirmPasswordTF: UITextField!
    class func instance() -> UIViewController {
        return ChangePassVC()
    }
    
    typealias ViewModelType = ChangePassViewModel
    
    init() {
        super.init(nibName: "ChangePassVC", bundle: nil)
        viewModel = ChangePassViewModel(displayLogic: self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewModel = ChangePassViewModel(displayLogic: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bindViewModel() {
        let input = ChangePassViewModel.Input(
            changePassTrigger: changePasswordButton.rx.tap.asDriver(),
            oldPassword: oldPasswordTF.rx.text.orEmpty,
            newPassword: newPasswordTF.rx.text.orEmpty,
            confirmPassword: confirmPasswordTF.rx.text.orEmpty,
            cancelTrigger: cancelButton.rx.tap.asDriver())
        
        let output = self.viewModel.transform(input: input)
        
        output.error
            .drive(onNext: { [unowned self] (error) in
                self.handleError(e: error)
            })
            .disposed(by: self.disposeBag)
    }
}

extension ChangePassVC :  ChangePassDisplayLogic {
    func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showSuccess() {
        let alertController = UIAlertController(
            title: "Password changed",
            message: "Your password has been changed successfully.",
            preferredStyle: .alert)
        let defaultAction = UIAlertAction(
            title: "Got it!",
            style: .cancel,
            handler: { [unowned self] (_) in
                self.goBack()
        })
        
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showFail() {
        self.view.makeToast("Cannot change password. The old password is not correct", duration: 3.0, position: CSToastPositionBottom)
    }
}
