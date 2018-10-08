import RxSwift

class ResendUseCase : UseCase {
    typealias TRequest = ResendRequest
    typealias TRespond = Bool
    
    private let repository: ConversationRepository =
        ConversationRepositoryFactory.sharedInstance
    
    func execute(request: ResendRequest) -> Observable<Bool> {
        return repository.resendMessage(request: request)
    }
}
