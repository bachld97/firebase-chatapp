import RxSwift

class SendMessageUseCase : UseCase {
    typealias TRequest = SendMessageRequest
    typealias TResponse = Bool
    private let repository: ConversationRepository = ConversationRepositoryFactory.sharedInstance
    
    func execute(request: SendMessageRequest) -> Observable<Bool> {
        return repository.sendMessage(request)
    }
}
