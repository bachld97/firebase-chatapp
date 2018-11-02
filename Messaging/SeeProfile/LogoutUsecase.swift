import RxSwift

class LogoutUseCase : UseCase {
    typealias TRequest = Void
    typealias TRespond = Bool
    
    private let repository = UserRepositoryFactory.sharedInstance
    
    func execute(request: Void) -> Observable<Bool> {
        return repository.logout()
    }
}
