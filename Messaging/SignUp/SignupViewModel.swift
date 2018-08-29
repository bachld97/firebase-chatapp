import RxSwift
import RxCocoa

protocol SignupDisplayLogic : class {
    func hideKeyboard()
    func goMain() // Register success, log user in
}

class SignupViewModel : ViewModelDelegate {
    private let disposeBag : DisposeBag
    
    private let username = BehaviorRelay<String>(value: "")
    private let password = BehaviorRelay<String>(value: "")
    private let confirmPassword = BehaviorRelay<String>(value: "")
    private let fullname = BehaviorRelay<String>(value: "")
    
    private let signupUsecase = SignupUseCase()
    private weak var displayLogic : SignupDisplayLogic?
    
    init(displayLogic: SignupDisplayLogic) {
        self.displayLogic = displayLogic
        disposeBag = DisposeBag()
    }
    
    func transform(input: SignupViewModel.Input) -> SignupViewModel.Output {
        // let signupSuccess = PublishSubject<Void>()
        let error = PublishSubject<Error>()
        
        // signupSuccess.disposed(by: self.disposeBag)
        error.disposed(by: self.disposeBag)
        
        (input.username <-> self.username)
            .disposed(by: self.disposeBag)
        
        (input.password <-> self.password)
            .disposed(by: self.disposeBag)
        
        (input.confirmPassword <-> self.confirmPassword)
            .disposed(by: self.disposeBag)
        
        (input.fullname <-> self.fullname)
            .disposed(by: self.disposeBag)
        
        input.signupTrigger
            .flatMap { [unowned self] (_) -> Driver<Bool> in
                self.displayLogic?.hideKeyboard()
                return Observable.deferred { [unowned self] in
                    guard !self.username.value.isEmpty &&
                        !self.password.value.isEmpty &&
                        !self.confirmPassword.value.isEmpty &&
                        !self.fullname.value.isEmpty else {
                            return Observable.error(SimpleError(message: "All fields are required"))
                    }
                    
                    guard self.password.value
                        .elementsEqual(self.confirmPassword.value) else {
                            return Observable.error(SimpleError(message: "The passwords you entered do not match"))
                    }
                    
                    let request = SignupRequest(username: self.username.value,
                                                password: self.password.value,
                                                fullname: self.fullname.value)
                    return Observable.just(request)
                }
                .flatMap { [unowned self] (request) -> Observable<Bool> in
                    return self.signupUsecase
                        .execute(request: request)
                        .do(onNext: { [unowned self] (success) in
                            if success {
                                self.displayLogic?.goMain()
                            } else {
                                error.onError(SimpleError(message: "Username is taken"))
                            }
                        })
                }
                .asDriverIfErrorNotify(error)
            }
        .drive()
        .disposed(by: self.disposeBag)

        
        return Output(
            // signupSuccess: signupSuccess.asSingle(),
            error: error.asDriverOnErrorJustComplete())
    }
}

extension SignupViewModel {
    struct Input {
        let signupTrigger: Driver<Void>
        let username: ControlProperty<String>
        let password: ControlProperty<String>
        let confirmPassword: ControlProperty<String>
        let fullname: ControlProperty<String>
    }
    
    struct Output {
        // let signupSuccess: Single<Void>
        let error: Driver<Error>
    }
}
