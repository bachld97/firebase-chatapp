import RxSwift
import RxCocoa

protocol SeeChatHistoryDisplayLogic: class {
    func goConversation(item: ConversationItem)
    func showEmpty()
}
class SeeChatHistoryViewModel: ViewModelDelegate {
    
    init(displayLogic: SeeChatHistoryDisplayLogic) {
        self.displayLogic = displayLogic
        self.disposeBag = DisposeBag()
    }
    
    private let disposeBag: DisposeBag
    private weak var displayLogic : SeeChatHistoryDisplayLogic?
    private let seeChatHistoryUseCase = SeeChatHistoryUseCase()
    
    public let items = BehaviorRelay<[Item]>(value: [])
    
    func transform(input: SeeChatHistoryViewModel.Input) -> SeeChatHistoryViewModel.Output {
        let errorTracker = ErrorTracker()
        
        input.trigger
            .flatMap { [unowned self] (_) -> Driver<[Conversation]> in
                return Observable.deferred { [unowned self] in
                    return self.seeChatHistoryUseCase
                        .execute(request: ())
                        .do(onNext: { [unowned self] in
                            var items: [Item] = []
                            
                            items.append(contentsOf: $0.map { (conversation) in
                                let convoItem = ConversationItem(conversation: conversation)
                                switch conversation.type {
                                case .group:
                                    return Item(convoItem: convoItem, convoType: .group)
                                case .single:
                                    return Item(convoItem: convoItem, convoType: .single)
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
        
        //        TODO: Use publishSubject to establish reload (pull to refresh)
//        input.reloadTrigger
//            .flatMap { [unowned self] (_) -> Driver<[Conversation]> in
//                return Observable.deferred { [unowned self] in
//                    return self.seeChatHistoryUseCase
//                        .execute(request: ())
//                        .do(onNext: { [unowned self] (conversations) in
//                            // TODO: Inflate the table
//                        })
//                    }
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

extension SeeChatHistoryViewModel {
    struct Input {
        let trigger: Driver<Void>
    }
    
    struct Output {
        let error: Driver<Error>
        let items: Driver<[Item]>
    }
    
    class Item {
        let convoItem: ConversationItem
        let convoType: ItemType
        
        init(convoItem: ConversationItem, convoType: ItemType) {
            self.convoItem = convoItem
            self.convoType = convoType
        }
    }
    
    enum ItemType {
        case single
        case group
    }
}
