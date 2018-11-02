import RxSwift


class SearchContactUseCase : UseCase {
    typealias TRequest = SearchContactRequest
    
    typealias TResponse = [ContactRequest]
    
    private let repository: ContactRepository = ContactRepositoryFactory.sharedInstance
    
    func execute(request: SearchContactRequest) -> Observable<[ContactRequest]> {
        return repository.searchContact(request: request)
    }
}

