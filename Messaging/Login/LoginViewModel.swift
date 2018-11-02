import RxSwift
import RxCocoa

protocol LoginDisplayLogic : class {
	func goSignup()
	func goMain()
	func hideKeyboard()
}

final class LoginViewModel : ViewModelDelegate {
	private let disposeBag : DisposeBag

	private let username = BehaviorRelay<String>(value: "")
	private let password = BehaviorRelay<String>(value: "")
    private let loginUseCase = LoginUseCase()
    private let autoLoginUseCase = AutoLoginUseCase()
	private weak var displayLogic: LoginDisplayLogic?

	init(displayLogic: LoginDisplayLogic) {
		self.displayLogic = displayLogic
        self.disposeBag = DisposeBag()
	}

	func transform(input: Input) -> Output {
        // let success = PublishSubject<Void>()
        let errorTracker = ErrorTracker()

		(input.username <-> self.username)
			.disposed(by: self.disposeBag) 
		(input.password <-> self.password)
			.disposed(by: self.disposeBag)
        
        input.trigger
            .flatMap { [unowned self] (_) -> Driver<Bool> in
                return self.autoLoginUseCase
                    .execute(request: ())
                    .do(onNext: { [unowned self] (result) in
                        if result {
                            self.displayLogic?.goMain()
                        }
                    })
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)

		input.signUpTrigger
			.drive(onNext: { [unowned self] in // Similar to .subscribe()
					self.displayLogic?.goSignup()
			})
			.disposed(by: self.disposeBag)

        input.loginTrigger
            .flatMap { [unowned self] (_) -> Driver<Bool> in
                self.displayLogic?.hideKeyboard()
                return Observable.deferred { [unowned self] in
                        guard !self.username.value.isEmpty else {
                            return Observable.error(SimpleError(message: "Username cannot be left empty"))
                        }
    
                        guard !self.password.value.isEmpty else {
                            return Observable.error(SimpleError(message: "Password cannot be left empty"))
                        }
    
                        let request = LoginRequest(username: self.username.value, password: self.password.value)
                        return Observable.just(request)
                    }
                    .flatMap { [unowned self] (request) -> Observable<Bool> in
                        return self.loginUseCase.execute(request: request)
                            .do(onNext: { [unowned self] (_: Bool) in
                                // login will throw error if login info is wrong
                                self.displayLogic?.goMain()
                            })
                    }
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
        }
        .drive()
        .disposed(by: self.disposeBag)
        
        // TODO: How to create an observable here?
        // success.disposed(by: disposeBag)
        return Output(
            // loginSuccess: success.asSingle(),
            error: errorTracker.asDriver())
	}
}

extension LoginViewModel {
	public struct Input {
        let trigger: Driver<Void>
		let signUpTrigger: Driver<Void>
		let loginTrigger: Driver<Void>
        let username: ControlProperty<String>
        let password: ControlProperty<String>
	}

	public struct Output {
        // let loginSuccess: Single<Void>
        let error: Driver<Error>
	}
}

