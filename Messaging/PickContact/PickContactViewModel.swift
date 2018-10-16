import RxSwift
import RxCocoa

protocol PickContactDelegate : class {
    func onContactChoosen(contact: Contact)
}

class PickContactViewModel : ViewModelDelegate {
    
    private let disposeBag: DisposeBag = DisposeBag()
    private let items = BehaviorRelay<[ContactItem]>(value: [])
    private let seeContactUseCase = SeeContactUseCase()
    
    func transform(input: PickContactViewModel.Input) -> PickContactViewModel.Output {
        let errorTracker = ErrorTracker()
        input.trigger
            .flatMap { [unowned self] (_) -> Driver<[Contact]> in
                return Observable.deferred { [unowned self] in
                    return self.seeContactUseCase
                        .execute(request: ())
                        .do(onNext: { [unowned self] (contacts) in
                            var items: [ContactItem] = []
                            items.append(contentsOf: contacts.map { contact in
                                return ContactItem(contact: contact)
                            })
                            self.items.accept(items)
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

extension PickContactViewModel {
    struct Input {
        let trigger: Driver<Void>
    }
    
    struct Output {
        let error: Driver<Error>
        let items: Driver<[ContactItem]>
    }
}
