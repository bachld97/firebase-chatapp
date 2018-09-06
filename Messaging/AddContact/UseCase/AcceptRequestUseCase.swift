import RxSwift

class AcceptRequestUseCase : UseCase {
    typealias TRequest = AcceptFriendRequest
    typealias TResponse = Bool
    
    private let repository: ContactRepository = ContactRepositoryFactory.sharedInstance
    
    func execute(request: AcceptFriendRequest) -> Observable<Bool> {
        return repository.acceptRequest(request: request)
    }
}

