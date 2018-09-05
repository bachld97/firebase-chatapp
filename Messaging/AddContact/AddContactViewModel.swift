import RxSwift
import RxCocoa
import RxDataSources

protocol AddContactDisplayLogic: class {
    func goBack()
    func hideKeyboard()
}

class AddContactViewModel: ViewModelDelegate {
    private weak var displayLogic: AddContactDisplayLogic?
    private let disposeBag: DisposeBag
    private let searchQuery = BehaviorRelay<String>(value: "")
    private let addContactUseCase = AddContactUseCase()
    private let searchContactUseCase = SearchContactUseCase()
    public let items = BehaviorRelay<[Item]>(value: [])
    
    init(displayLogic: AddContactDisplayLogic) {
        self.disposeBag = DisposeBag()
        self.displayLogic = displayLogic
    }
    
    func transform(input: Input) -> Output {
        let errorTracker = ErrorTracker()
        (input.searchQuery <-> searchQuery)
            .disposed(by: self.disposeBag)

        input.goBackTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.goBack()
            })
            .disposed(by: self.disposeBag)
        
        input.searchTrigger
            .flatMap { [unowned self] (_) -> Driver<[ContactRequest]> in
                self.displayLogic?.hideKeyboard()
                return Observable.deferred { [unowned self] in
//                    guard !self.searchQuery.value.isEmpty else {
//                        return Observable.error(EmptyQueryError())
//                    }
                    
                    return Observable.just(SearchContactRequest(searchString: self.searchQuery.value))
                    }
                    .flatMap { [unowned self] (request) -> Observable<[ContactRequest]> in
                        return self.searchContactUseCase.execute(request: request)
                            .do(onNext: { [unowned self] (contactRequests: [ContactRequest]) in
                                var items: [Item] = []
                                // TODO: Display list of results into a TableView
                                items.append(contentsOf: contactRequests.map { (request) in
                                    let contactItem = ContactItem(contact: request.contact)
                                    switch request.relation {
                                    case .accepted:
                                        return Item.accepted(contactItem)
                                    case .requested:
                                        return Item.requested(contactItem)
                                    case .requesting:
                                        return Item.requesting(contactItem)
                                    case .stranger:
                                        return Item.stranger(contactItem)
                                    }
                                })
                                self.items.accept(items)
                            })
                    }
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)
        
        
        // TODO: Different trigger for different use case?
        // Accept, Request, Cancel request (change state in 2 places)
        // TODO: Make separated section for Requesting, Requested, Stranger
//        input.addTrigger
//            .flatMap { [unowned self] (contact) in
//                self.addContactUseCase
//                    .execute(request: AddContactRequest(contactToAdd: contact))
//                    .do(onNext: { (_) in
//                        // TODO: Change state of newly requested user from stranger to requested
//                    })
//                    .trackError(errorTracker)
//                    .asDriverOnErrorJustComplete()
//            }
//            .drive()
//            .disposed(by: self.disposeBag)
        
        
        return Output(
            error: errorTracker.asDriver(),
            items: self.items.asDriver())
    }
}

extension AddContactViewModel {
    struct Input {
        let goBackTrigger: Driver<Void>
        let searchQuery: ControlProperty<String>
        let searchTrigger: Driver<Void>
        // let addTrigger: Driver<Contact>
    }
    
    struct Output {
        let error: Driver<Error>
        let items: Driver<[Item]>
    }
    
    enum Item {
        case requested(ContactItem) // This user requested to add you as friend
        case requesting(ContactItem) // You requested to add this user
        case stranger(ContactItem) // Complete stranger
        case accepted(ContactItem) // Added
    }
}
