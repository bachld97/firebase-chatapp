import RxSwift

final class LoadConvoFromContactIdUseCase : UseCase {
    typealias TRequest = LoadConvoFromContactIdRequest
    typealias TRespond = [Message]
    
    private let repository: ConversationRepository = ConversationRepositoryFactory.sharedInstance
    
    func execute(request: LoadConvoFromContactIdRequest) -> Observable<[Message]> {
        return repository.loadMessages(with: request.contactId)
    }
}
