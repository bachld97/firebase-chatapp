import RxSwift

class SeeChatHistoryUseCase: UseCase {
    
    typealias TRequest = SeeChatHistoryRequest
    typealias TResponse = [Conversation]?
    
    private let repository: ConversationRepository = ConversationRepositoryFactory.sharedInstance
    func execute(request: SeeChatHistoryRequest) -> Observable<[Conversation]?> {
        return repository.loadChatHistory()
    }
}
