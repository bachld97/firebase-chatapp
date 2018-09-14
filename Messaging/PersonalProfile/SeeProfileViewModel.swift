import RxSwift
import RxCocoa

protocol SeeProfileDisplayLogic : class {
    func goChangePass()
    func display(user: User)
    func logout()
    func showPicker()
}

class SeeProfileViewModel : ViewModelDelegate {
    
    private weak var displayLogic: SeeProfileDisplayLogic?
    private let disposeBag: DisposeBag
    private let seeProfileUseCase = SeeProfileUseCase()
    private let uploadAvatarUsecas = UploadAvatarUseCase()
    
    init(displayLogic: SeeProfileDisplayLogic) {
        self.displayLogic = displayLogic
        self.disposeBag = DisposeBag()
    }
    
    func transform(input: SeeProfileViewModel.Input) -> SeeProfileViewModel.Output {
        let errorTracker = ErrorTracker()
        
        input.trigger
            .flatMap { [unowned self] (_) -> Driver<User> in
                return Observable.deferred {
                    return self.seeProfileUseCase
                    .execute(request: ())
                        .do(onNext: { [unowned self] user in
                            self.displayLogic?.display(user: user)
                        })
                }
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        }
        .drive()
        .disposed(by: disposeBag)

//        input.reloadTrigger
//            .flatMap { [unowned self] (_) -> Driver<User> in
//                return Observable.deferred {
//                    return self.seeProfileUseCase
//                        .execute(request: ())
//                        .do(onNext: { [unowned self] user in
//                            self.displayLogic?.display(user: user)
//                        })
//                    }
//                    .trackError(errorTracker)
//                    .asDriverOnErrorJustComplete()
//            }
//            .drive()
//            .disposed(by: disposeBag)

        input.changePassTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.goChangePass()
            })
            .disposed(by: self.disposeBag)
        
        // Should evoke logoutUseCase as well
        input.logoutTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.logout()
            })
            .disposed(by: self.disposeBag)
        
        input.showPickerTrigger
            .drive(onNext: { [unowned self] (_)in
                self.displayLogic?.showPicker()
            })
            .disposed(by: self.disposeBag)

        input.uploadAvaTrigger
            .flatMap { [unowned self] (url) in
                return self.uploadAvatarUsecas
                    .execute(request: UploadAvatarRequest(url: url))
                    .do()
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)
        
        return Output(
            error: errorTracker.asDriver())
    }
}

extension SeeProfileViewModel {
    struct Input {
        let trigger: Driver<Void>
        // let reloadTrigger: Driver<Void>
        let logoutTrigger: Driver<Void>
        let changePassTrigger: Driver<Void>
        let showPickerTrigger: Driver<UITapGestureRecognizer>
        let uploadAvaTrigger: Driver<URL>
    }
    
    struct Output {
        let error: Driver<Error>
    }
}
