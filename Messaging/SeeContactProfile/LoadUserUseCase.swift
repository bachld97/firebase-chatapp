import RxSwift

class LoadUserUseCase : UseCase {
    typealias TRequest = LoadUserRequest
    typealias TResponse = Contact
    
    private let repository = ContactRepositoryFactory.sharedInstance
    
    func execute(request: LoadUserRequest) -> Observable<Contact> {
        return self.repository.seeOneContact(withId: request.idToLoad)
    }
}
