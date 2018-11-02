import RxSwift

final class LoadConvoFromConvoIdUseCase : UseCase {
    typealias TRequest = LoadConvoFromConvoIdRequest
    typealias TResponse = [Message]
    
    private let repository: ConversationRepository = ConversationRepositoryFactory.sharedInstance
    
    func execute(request: LoadConvoFromConvoIdRequest) -> Observable<[Message]> {
        return repository.loadMessages(of: request.convoId)
    }
}
