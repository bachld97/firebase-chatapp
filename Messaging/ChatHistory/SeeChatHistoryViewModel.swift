import RxSwift
import RxCocoa

protocol SeeChatHistoryDisplayLogic: class {
    func goConversation()
    func showEmpty()
    func showChatHistory(conversations: [Conversation]?)
}

class SeeChatHistoryViewModel: ViewModelDelegate {
    
    init(displayLogic: SeeChatHistoryDisplayLogic) {
        self.displayLogic = displayLogic
        self.disposeBag = DisposeBag()
    }
    
    private let disposeBag: DisposeBag
    private weak var displayLogic : SeeChatHistoryDisplayLogic?
    private let seeChatHistoryUseCase = SeeChatHistoryUseCase()
    
    func transform(input: SeeChatHistoryViewModel.Input) -> SeeChatHistoryViewModel.Output {
        let errorTracker = ErrorTracker()
        
        input.trigger
            .flatMap { [unowned self] (_) -> Driver<[Conversation]?> in
                return Observable.deferred { [unowned self] in
                    return self.seeChatHistoryUseCase
                        .execute(request: ())
                        .do(onNext: { [unowned self] (conversations) in
                            if conversations != nil {
                                self.displayLogic?.showChatHistory(conversations: conversations!)
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
            .flatMap { [unowned self] (_) -> Driver<[Conversation]?> in
                return Observable.deferred { [unowned self] in
                    return self.seeChatHistoryUseCase
                        .execute(request: ())
                        .do(onNext: { [unowned self] (conversations) in
                            if conversations != nil {
                                self.displayLogic?.showChatHistory(conversations: conversations!)
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
        
        return Output(
            error: errorTracker.asDriver())
    }
}

extension SeeChatHistoryViewModel {
    struct Input {
        let trigger: Driver<Void>
        let reloadTrigger: Driver<Void>
    }
    
    struct Output {
        let error: Driver<Error>
    }
}
