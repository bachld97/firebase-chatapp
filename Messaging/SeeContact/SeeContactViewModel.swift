import RxSwift
import RxCocoa

protocol SeeContactDisplayLogic : class {
    func goConversation()
    func showEmpty()
}

final class SeeContactViewModel : ViewModelDelegate {
    
    public let items = BehaviorRelay<[ContactItem]>(value: [])
    
    private let disposeBag : DisposeBag
    private weak var displayLogic: SeeContactDisplayLogic?
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
                        .execute(request: ())
                        .do(onNext: { [unowned self] (contacts) in
                            if contacts != nil {
                                var items: [ContactItem] = []
                                items.append(contentsOf: contacts!.map { contact in
                                    return ContactItem(contact: contact)
                                })
                                self.items.accept(items)
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
                        .execute(request: ())
                        .do(onNext: { [unowned self] (contacts) in
                            if contacts != nil {
                                var items: [ContactItem] = []
                                items.append(contentsOf: contacts!.map { contact in
                                    return ContactItem(contact: contact)
                                })
                                self.items.accept(items)
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
        
        
        return Output(error: errorTracker.asDriver(),
                      items: self.items.asDriver())
    }
}

extension SeeContactViewModel {
    public struct Input {
        let trigger: Driver<Void>
        let reloadTrigger: Driver<Void>
    }
    
    public struct Output {
        let error: Driver<Error>
        let items: Driver<[ContactItem]>
    }
}
