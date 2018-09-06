import RxSwift

class UnfriendUseCase: UseCase {
    typealias TRequest = UnfriendRequest
    typealias TResponse = Bool
    
    private let repository: ContactRepository = ContactRepositoryFactory.sharedInstance

    func execute(request: UnfriendRequest) -> Observable<Bool> {
        return repository.unfriendRequest(request: request)
    }
}

