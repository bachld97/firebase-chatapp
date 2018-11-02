import RxSwift
import RxCocoa
import DeepDiff

protocol SeeChatHistoryDisplayLogic: class {
    func goConversation(item: ConversationItem)
    func showEmpty()
    
    func notifyItems(with changes: [Change<ConversationItem>]?)
}
class SeeChatHistoryViewModel: ViewModelDelegate {
    
    init(displayLogic: SeeChatHistoryDisplayLogic) {
        self.displayLogic = displayLogic
        self.disposeBag = DisposeBag()
    }
    
    private let dataSource = ConversationItemDataSource()
    private let disposeBag: DisposeBag
    private weak var displayLogic : SeeChatHistoryDisplayLogic?
    private let seeChatHistoryUseCase = SeeChatHistoryUseCase()
    
    func transform(input: SeeChatHistoryViewModel.Input) -> SeeChatHistoryViewModel.Output {
        let errorTracker = ErrorTracker()
        
        input.trigger
            .flatMap { [unowned self] (_) -> Driver<[ConversationItem]> in
                return Observable.deferred { [unowned self] in
                    return self.seeChatHistoryUseCase
                        .execute(request: ())
                        .do()
                        .flatMap { (conversations) -> Observable<[ConversationItem]> in
                            var items: [ConversationItem] = []
                            
                            items.append(contentsOf: conversations.map {
                                ConversationItem(conversation: $0)
                            })
                            
                            return Observable.just(items)
                    }
                    }
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive(onNext: { [unowned self] (convItems) in
                DispatchQueue.main.async {
                    let changes = self.dataSource.setItems(items: convItems)
                    self.displayLogic?.notifyItems(with: changes)
                }
            })
            .disposed(by: self.disposeBag)
        
        input.conversationTrigger
            .drive(onNext: { [unowned self] (index) in
                self.displayLogic?.goConversation(item: self.dataSource.getItem(atIndex: index))
            })
            .disposed(by: self.disposeBag)
        
        return Output(
            error: errorTracker.asDriver(),
            dataSource: self.dataSource)
    }
}

extension SeeChatHistoryViewModel {
    struct Input {
        let trigger: Driver<Void>
        let conversationTrigger: Driver<Int>
    }
    
    struct Output {
        let error: Driver<Error>
        let dataSource: UITableViewDataSource
    }
}
