import RxSwift
import RxCocoa
import RxDataSources

protocol AddContactDisplayLogic: class {
    func goBack()
    func hideKeyboard()
    func goConversation(_ item: ContactItem)
}

class AddContactViewModel: ViewModelDelegate {
    private weak var displayLogic: AddContactDisplayLogic?
    private let disposeBag: DisposeBag
    private let searchQuery = BehaviorRelay<String>(value: "")
    
    // private let addContactUseCase = AddContactUseCase()
    private let searchContactUseCase = SearchContactUseCase()
    
    private let acceptRequestUseCase = AcceptRequestUseCase()
    private let cancelRequestUseCase = CancelRequestUseCase()
    private let sendRequestUseCase = SendRequestUseCase()
    private let unfriendUseCase = UnfriendUseCase()
    
    public let items = BehaviorRelay<[Item]>(value: [])
    
    init(displayLogic: AddContactDisplayLogic) {
        self.disposeBag = DisposeBag()
        self.displayLogic = displayLogic
    }
    
    func transform(input: Input) -> Output {
        let errorTracker = ErrorTracker()
        (input.searchQuery <-> searchQuery)
            .disposed(by: self.disposeBag)
        
        input.trigger
            .flatMap { [unowned self] (_) -> Driver<[ContactRequest]> in
                self.displayLogic?.hideKeyboard()
                return Observable.deferred { [unowned self] () -> Observable<[ContactRequest]> in
                    let request = SearchContactRequest(searchString: "")
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

        input.goBackTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.goBack()
            })
            .disposed(by: self.disposeBag)
        
        input.searchTrigger
            .flatMap { [unowned self] (_) -> Driver<[ContactRequest]> in
                self.displayLogic?.hideKeyboard()
                return Observable.deferred { [unowned self] () -> Observable<[ContactRequest]> in
                    let request = SearchContactRequest(searchString: self.searchQuery.value)
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
        
        input.messageTrigger
            .drive(onNext: { [unowned self] (contactItem) in
                self.displayLogic?.goConversation(contactItem)
            })
            .disposed(by: self.disposeBag) 
        
        input.acceptTrigger
            .flatMap { [unowned self] (contactItem) -> Driver<Bool> in
                return self.acceptRequestUseCase
                    .execute(request: AcceptFriendRequest(acceptedContact: contactItem.contact))
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)
        
        
        input.addTrigger
            .flatMap { [unowned self] (contactItem) -> Driver<Bool> in
                return self.sendRequestUseCase
                    .execute(request: AddFriendRequest(contactToAdd: contactItem.contact))
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)
        
        input.cancelTrigger
            .flatMap { [unowned self] (contactItem) -> Driver<Bool> in
                return self.cancelRequestUseCase
                    .execute(request: CancelFriendRequest(canceledContact: contactItem.contact))
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)
        
        input.unfriendTrigger
            .flatMap { [unowned self] (contactItem) -> Driver<Bool> in
                return self.unfriendUseCase
                    .execute(request: UnfriendRequest(contactToRemove: contactItem.contact))
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)
        
        return Output(
            error: errorTracker.asDriver(),
            items: self.items.asDriver())
    }
}

extension AddContactViewModel {
    struct Input {
        let trigger: Driver<Void>
        let goBackTrigger: Driver<Void>
        let searchQuery: ControlProperty<String>
        let searchTrigger: Driver<Void>
        
        let messageTrigger: Driver<ContactItem>
        let unfriendTrigger: Driver<ContactItem>
        let cancelTrigger: Driver<ContactItem>
        let acceptTrigger: Driver<ContactItem>
        let addTrigger: Driver<ContactItem>
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
