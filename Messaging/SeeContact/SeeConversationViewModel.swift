import RxSwift
import RxCocoa

protocol SeeConversationDisplayLogic : class {
    func goBack()
}

class SeeConversationViewModel : ViewModelDelegate {
    private weak var displayLogic: SeeConversationDisplayLogic?
    private let disposeBag: DisposeBag
    
    let contactItem: ContactItem?
    // let chatHistoryItem: ChatHistoryItem?

    
    init(displayLogic: SeeConversationDisplayLogic, contactItem: ContactItem) {
        self.displayLogic = displayLogic
        self.contactItem = contactItem
        self.disposeBag = DisposeBag()
        // self.chatHistoryItem = nil
    }

    // init(displayLogic: SeeConversationDisplayLogic, chatHistoryItem: ChatHistoryItem) { }
    
    func transform(input: Input) -> Output {
        let errorTracker = ErrorTracker()
        
        guard contactItem != nil else {
            fatalError("Cannot load conversation if contactItem is nil")
        }
        
        (Observable.just(contactItem)
            .map { "\($0!.contact.userName)" }
            .bind(to: input.conversationLabel)
            ).disposed(by: self.disposeBag)
        
//        input.trigger...

        input.goBackTrigger
            .drive(onNext: { [unowned self] in
                self.displayLogic?.goBack()
            })
        .disposed(by: self.disposeBag)

        return Output(
            error: errorTracker.asDriver())
    }
}

extension SeeConversationViewModel {
    struct Input {
        let trigger: Driver<Void>
        let goBackTrigger: Driver<Void>
        let conversationLabel: Binder<String?>
    }
    
    struct Output {
        let error: Driver<Error>
    }
}
