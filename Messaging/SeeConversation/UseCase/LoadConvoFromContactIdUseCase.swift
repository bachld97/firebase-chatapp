import RxSwift

final class LoadConvoFromContactIdUseCase : UseCase {
    typealias TRequest = LoadConvoFromContactRequest
    typealias TRespond = [Message]
    
    private let repository: ConversationRepository = ConversationRepositoryFactory.sharedInstance
    
    func execute(request: LoadConvoFromContactRequest) -> Observable<[Message]> {
        
        return repository.loadMessages(with: request.contact)
    }
}
