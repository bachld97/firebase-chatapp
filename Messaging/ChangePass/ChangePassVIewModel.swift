import RxSwift
import RxCocoa

protocol ChangePassDisplayLogic : class {
    func goBack()
    func showFail()
    func showSuccess()
}

class ChangePassViewModel: ViewModelDelegate {
    
    private let disposeBag: DisposeBag
    private weak var displayLogic: ChangePassDisplayLogic?
    private let changePassUseCase = ChangePassUseCase()
    
    private let oldPassword = BehaviorRelay<String>(value: "")
    private let newPassword = BehaviorRelay<String>(value: "")
    private let confirmPassword = BehaviorRelay<String>(value: "")
    
    init(displayLogic: ChangePassDisplayLogic) {
        self.displayLogic = displayLogic
        self.disposeBag = DisposeBag()
    }
    
    func transform(input: Input) -> Output {
        let errorTracker = ErrorTracker()
        
        (input.oldPassword <-> self.oldPassword)
            .disposed(by: self.disposeBag)
        
        (input.newPassword <-> self.newPassword)
            .disposed(by: self.disposeBag)
        
        (input.confirmPassword <-> self.confirmPassword)
            .disposed(by: self.disposeBag)
        
        input.changePassTrigger
            .flatMap { [unowned self] (_) -> Driver<Bool> in
                return Observable.deferred { [unowned self] in
                    guard !self.oldPassword.value.isEmpty &&
                        !self.confirmPassword.value.isEmpty &&
                        !self.newPassword.value.isEmpty else {
                            return Observable.error(SimpleError(message: "All fields are required"))
                    }
                    
                    guard self.newPassword.value
                        .elementsEqual(self.confirmPassword.value) else {
                            return Observable.error(SimpleError(message: "The passwords you entered do not match"))
                    }
                    
                    let request = ChangePassRequest(oldPass: self.oldPassword.value, newPass: self.newPassword.value)
                    return Observable.just(request)
                }
                .flatMap { [unowned self] (request) -> Observable<Bool> in
                    return self.changePassUseCase
                        .execute(request: request)
                        .do(onNext: { [unowned self] (success) in
                            if success {
                                self.displayLogic?.showSuccess()
                            } else {
                                self.displayLogic?.showFail()
                            }
                        })
                }
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)
        
        input.cancelTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.goBack()
            })
        .disposed(by: self.disposeBag)

        return Output(error: errorTracker.asDriver())
    }
}

extension ChangePassViewModel {
    struct Input {
        let changePassTrigger: Driver<Void>
        let oldPassword: ControlProperty<String>
        let newPassword: ControlProperty<String>
        let confirmPassword: ControlProperty<String>
        let cancelTrigger: Driver<Void>
    }
    
    struct Output {
        let error: Driver<Error>
    }
}
