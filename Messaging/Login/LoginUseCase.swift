import RxSwift

class LoginUseCase : UseCase {
    typealias TRequest = LoginRequest
    typealias TResponse = Bool
    
    let repository: UserRepository = UserRepositoryFactory.sharedInstance
    
    func execute(request: LoginRequest) -> Observable<Bool> {
        return repository.login(request: request)
    }
}
