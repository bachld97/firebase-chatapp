import RxSwift
import RxCocoa

class ObserveNextMessageUseCase : UseCase {
    typealias TRequest = ObserveNextMessageRequest
    typealias TResponse = Message
    
    private let repository: ConversationRepository =
        ConversationRepositoryFactory.sharedInstance
    
    func execute(request: ObserveNextMessageRequest) -> Observable<Message> {
        return repository.observeNextMessage(fromLastId: request.fromLastId)
    }
}
