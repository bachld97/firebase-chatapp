import RxSwift

class AutoLoginUseCase : UseCase {
    private let repository: UserRepository = UserRepositoryFactory.sharedInstance
    typealias TRequest = Void
    typealias TRespond = Bool
    
    func execute(request: Void) -> Observable<Bool> {
        return repository
            .autoLogin()
    }
}
