import RxSwift
import RxCocoa

protocol SeeContactProfileDisplayLogic : class {
    func displayContactDetails(contact: Contact)
}

class SeeContactProfileViewModel : ViewModelDelegate {
    private let disposeBag: DisposeBag = DisposeBag()
    private let idToLoad: String
    private let loadUserInfoUseCase = LoadUserUseCase()
    
    private weak var displayLogic: SeeContactProfileDisplayLogic?
    
    init(idToLoad: String, displayLogic: SeeContactProfileDisplayLogic) {
        self.idToLoad = idToLoad
        self.displayLogic = displayLogic
    }
    
    func transform(input: Input) -> Output {
        let errorTracker = ErrorTracker()
        
        input.trigger
            .flatMap { [unowned self] (_) -> Driver<Contact> in
                return Observable.deferred {
                    return self.loadUserInfoUseCase.execute(
                        request: LoadUserRequest(idToLoad: self.idToLoad))
                    }
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive(onNext: { [unowned self] (contact) in
                self.displayLogic?.displayContactDetails(contact: contact)
            })
            .disposed(by: self.disposeBag)
        
        return Output(error: errorTracker.asDriver())
    }

}

extension SeeContactProfileViewModel {
    struct Input {
        let trigger: Driver<Void>
    }
    
    struct Output {
        let error: Driver<Error>
    }
}
