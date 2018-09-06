import RxSwift
class CancelRequestUseCase: UseCase {
    typealias TRequest = CancelFriendRequest
    typealias TResponse = Bool
    private let repository: ContactRepository = ContactRepositoryFactory.sharedInstance
 
    func execute(request: CancelFriendRequest) -> Observable<Bool> {
        return repository.cancelFriendRequest(request: request)
    }
}

