import RxSwift

class SignupUseCase : UseCase {
    typealias TRequest = SignupRequest
    typealias TResponse = Bool
    
    private let repository = UserRepositoryFactory.sharedInstance
    
    func execute(request: SignupRequest) -> Observable<Bool> {
        return repository.signup(request: request)
    }
}
