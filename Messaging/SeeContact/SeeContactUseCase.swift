import RxSwift

class SeeContactUseCase : UseCase {
    typealias TRequest = Void
    typealias TResponse = [Contact]
    
    private let repository: ContactRepository = ContactRepositoryFactory.sharedInstance
    
    public func execute(request: Void) -> Observable<[Contact]> {
        return repository.seeContact()
    }
}

