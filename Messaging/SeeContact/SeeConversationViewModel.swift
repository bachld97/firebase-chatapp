import RxSwift
import RxCocoa

protocol SeeConversationDisplayLogic : class {
    func goBack()
}

class SeeConversationViewModel : ViewModelDelegate {
    private weak var displayLogic: SeeConversationDisplayLogic?
    private let disposeBag: DisposeBag
    
    let contactItem: ContactItem?
    let conversationItem: ConversationItem?
    
    var cachedItems = [Item]()
    // We only listen to new item after the initial load,
    // additional data will be added to this list and publish to UI
    let items = BehaviorRelay<[Item]>(value: [])
    
    private let loadConvoFromContactIdUseCase = LoadConvoFromContactIdUseCase()
    private let loadConvoFromConvoIdUseCase = LoadConvoFromConvoIdUseCase()
    private let sendMessageUseCase = SendMessageUseCase()
    private let sendMessageToUserUseCase = SendMessageToUserUseCase()
    private let getConversationLabelUseCase = GetConversationLabelUseCase()
    private let getContactNicknameUseCase = GetContactNicknameUseCase()

    init(displayLogic: SeeConversationDisplayLogic, contactItem: ContactItem) {
        self.displayLogic = displayLogic
        self.contactItem = contactItem
        self.disposeBag = DisposeBag()
        self.conversationItem = nil
    }
    
    init(displayLogic: SeeConversationDisplayLogic, conversationItem: ConversationItem) {
        self.displayLogic = displayLogic
        self.conversationItem = conversationItem
        self.disposeBag = DisposeBag()
        self.contactItem = nil
    }

    // init(displayLogic: SeeConversationDisplayLogic, chatHistoryItem: ChatHistoryItem) { }
    
    func transform(input: Input) -> Output {
        if contactItem != nil {
            return transformWithContactItem(
                input: input, contactItem: contactItem!)
        }
        
        if conversationItem != nil {
            return transfromWithConversationItem(
                input: input, conversationItem: conversationItem!)
        }
        
        fatalError("ContactItem or ConversationItem must be not nil, or it is impossible to load conversation")
        
//        (Observable.just(contactItem)
//            .map { "\($0!.contact.userName)" }
//            .bind(to: input.conversationLabel)
//            ).disposed(by: self.disposeBag)
    }
    
    func transformWithContactItem(input: Input, contactItem: ContactItem) -> Output {
        let errorTracker = ErrorTracker()
        
        input.trigger
            .flatMap { [unowned self] (_) -> Driver<[Message]> in
                let request = LoadConvoFromContactRequest(contact: contactItem.contact)
                return self.loadConvoFromContactIdUseCase
                    .execute(request: request)
                    .do(onNext: { (messages) in
                        self.handleMessages(messages: messages)
                    })
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)

        input.sendMessTrigger
            .flatMap { [unowned self] (_) -> Driver<Bool> in
                let message = self.parseMessage()
                return self.sendMessageToUserUseCase
                    .execute(request: SendMessageToUserRequest(
                        message: message,
                        toUser: contactItem.contact))
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)

        
        self.getContactNicknameUseCase
            .execute(request: GetContactNickNameRequest(contact: contactItem.contact))
            .bind(to: input.conversationLabel)
            .disposed(by: self.disposeBag)
        
        return Output (
            error: errorTracker.asDriver(),
            items: items.asDriverOnErrorJustComplete())
    }
    
    func transfromWithConversationItem(input: Input, conversationItem: ConversationItem) -> Output {
        let errorTracker = ErrorTracker()
        input.trigger
            .flatMap { [unowned self] (_) -> Driver<[Message]> in
                let request = LoadConvoFromConvoIdRequest(convoId: conversationItem.conversation.id)
                return self.loadConvoFromConvoIdUseCase
                    .execute(request: request)
                    .do(onNext: { [unowned self] (messages) in
                        self.handleMessages(messages: messages)
                    })
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)
        
        input.sendMessTrigger
            .flatMap { [unowned self] (_) -> Driver<Bool> in
                let message = self.parseMessage()
                return self.sendMessageUseCase
                    .execute(request: SendMessageRequest(
                        message: message,
                        conversationId: conversationItem.conversation.id))
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: self.disposeBag)

        let request = GetConversationLabelRequest(
            conversationId: conversationItem.conversation.id)
        
        self.getConversationLabelUseCase
            .execute(request: request)
            .bind(to: input.conversationLabel)
            .disposed(by: self.disposeBag)
        
        return Output(
            error: errorTracker.asDriver(),
            items: items.asDriverOnErrorJustComplete())
    }
    
    private func handleMessages(messages: [Message]) {
        print(messages.count)
        
        self.cachedItems.append(Item.text())
        self.cachedItems.append(Item.text())

        self.items.accept(self.cachedItems)
    }
    
    private func parseMessage() -> Message {
        return Message()
    }
}

extension SeeConversationViewModel {
    struct Input {
        let trigger: Driver<Void>
        let sendMessTrigger: Driver<Void>
        let conversationLabel: Binder<String?>
    }
    
    struct Output {
        let error: Driver<Error>
        let items: Driver<[Item]>
    }
    
    enum Item {
        case text()
    }
}
