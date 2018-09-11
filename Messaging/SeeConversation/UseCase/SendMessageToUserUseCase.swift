import RxSwift

class SendMessageToUserUseCase : UseCase {
    typealias TRequest = SendMessageToUserRequest
    typealias TResponse = Bool
    
    private let repository: ConversationRepository =
        ConversationRepositoryFactory.sharedInstance

    func execute(request: SendMessageToUserRequest) -> Observable<Bool> {
        return repository.sendMessageToUser(request: request)
    }
}
