import RxSwift

class SeeChatHistoryUseCase: UseCase {
    
    typealias TRequest = Void
    typealias TResponse = [Conversation]?
    
    private let repository: ConversationRepository = ConversationRepositoryFactory.sharedInstance
    func execute(request: Void) -> Observable<[Conversation]?> {
        return repository
            .loadChatHistory()
    }
}
