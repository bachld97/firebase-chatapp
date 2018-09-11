import RxSwift
class GetConversationLabelUseCase: UseCase {
    typealias TRequest = GetConversationLabelRequest
    typealias TResponse = String
    
    private let repository: ConversationRepository
        = ConversationRepositoryFactory.sharedInstance
    
    func execute(request: GetConversationLabelRequest) -> Observable<String> {
        return repository.getConversationLabel(conversationId: request.conversationId)
    }
}

