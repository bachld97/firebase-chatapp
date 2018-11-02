import RxSwift
import RxCocoa

class ObserveNextMessageUseCase : UseCase {
    typealias TRequest = Void
    typealias TResponse = Message
    
    private let repository: ConversationRepository =
        ConversationRepositoryFactory.sharedInstance
    
    func execute(request: ()) -> Observable<Message> {
        return repository.observeNextMessage()
    }
}
