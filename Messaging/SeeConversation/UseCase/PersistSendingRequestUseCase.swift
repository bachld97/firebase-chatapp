import RxSwift

class PersistSendingMessageUseCase : UseCase {
    typealias TRequest = PersistSendingMessageRequest
    typealias TResponse = Message
    
    private let repository: ConversationRepository
        = ConversationRepositoryFactory.sharedInstance
    
    func execute(request: PersistSendingMessageRequest) -> Observable<Message> {
        return repository
            .persistSendingMessage(message: request.message)
    }
}
