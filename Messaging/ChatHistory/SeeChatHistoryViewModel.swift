import RxSwift
import RxCocoa

protocol SeeChatHistoryDisplayLogic: class {
    func goConversation()
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
    
    func transform(input: SeeChatHistoryViewModel.Input) -> SeeChatHistoryViewModel.Output {
        let errorTracker = ErrorTracker()
        
        input.trigger
            .flatMap { [unowned self] (_) -> Driver<[Conversation]> in
                return Observable.deferred { [unowned self] in
                    return self.seeChatHistoryUseCase
                        .execute(request: ())
                        .do(onNext: { [unowned self] in
                            // TODO: Inflate the table
                            $0.forEach {
                                print("\($0.nicknameDict)")
                            }
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
            error: errorTracker.asDriver())
    }
}

extension SeeChatHistoryViewModel {
    struct Input {
        let trigger: Driver<Void>
    }
    
    struct Output {
        let error: Driver<Error>
    }
}
