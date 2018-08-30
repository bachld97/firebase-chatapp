import RxSwift

class SeeContactUseCase : UseCase {
    typealias TRequest = SeeContactRequest
    typealias TResponse = [Contact]?
    
    private let repository = ContactRepositoryFactory.sharedInstance
    
    public func execute(request: SeeContactRequest) -> Observable<[Contact]?> {
        return repository.seeContact(request: request)
    }
}

