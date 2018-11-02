import RxSwift
class SendRequestUseCase: UseCase {
    typealias TRequest = AddFriendRequest
    typealias TResponse = Bool
    
    private let repository: ContactRepository = ContactRepositoryFactory.sharedInstance
    
    func execute(request: AddFriendRequest) -> Observable<Bool> {
        return repository.addFriendRequest(request: request)
    }
}

