import RxSwift
import RxCocoa

protocol SeeContactDisplayLogic : class {
    func goConversation()
    func forceLogout()
    func showEmpty()
    func displayContact(contacts: [Contact]?)
}

final class SeeContactViewModel : ViewModelDelegate {
    private let disposeBag : DisposeBag
    private weak var displayLogic: SeeContactDisplayLogic?
    
    // onTrigger: Load list of contacts
    private let seeContactUseCase = SeeContactUseCase()
    
    init(displayLogic: SeeContactDisplayLogic) {
        self.displayLogic = displayLogic
        self.disposeBag = DisposeBag()
    }
    
    func transform(input: Input) -> Output {
        let errorTracker = ErrorTracker()
        input.trigger
            .flatMap { [unowned self] (_) -> Driver<[Contact]?> in
                return Observable.deferred { [unowned self] in
                    return self.seeContactUseCase
                        .execute(request: SeeContactRequest())
                        .do(onNext: { [unowned self] (contacts) in
                            if contacts != nil {
                                self.displayLogic?.displayContact(contacts: contacts)
                            } else {
                                self.displayLogic?.showEmpty()
                            }
                        })
                    }
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)
        
        input.reloadTrigger
            .flatMap { [unowned self] (_) -> Driver<[Contact]?> in
                return Observable.deferred {
                    return self.seeContactUseCase
                        .execute(request: SeeContactRequest())
                        .do(onNext: { [unowned self] (contacts) in
                            if contacts != nil {
                                self.displayLogic?.displayContact(contacts: contacts)
                            } else {
                                self.displayLogic?.showEmpty()
                            }
                        })
                    }
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)
        
        
        return Output(error: errorTracker.asDriver())
    }
}

extension SeeContactViewModel {
    public struct Input {
        let trigger: Driver<Void>
        let reloadTrigger: Driver<Void>
    }
    
    public struct Output {
        let error: Driver<Error>
    }
}
