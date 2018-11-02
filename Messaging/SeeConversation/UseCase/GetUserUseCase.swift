import RxSwift

class GetUserUseCase : UseCase {
    typealias TRequest = Void
    typealias TResponse = User
    
    private let repository: UserRepository
        = UserRepositoryFactory.sharedInstance
    
    func execute(request: Void) -> Observable<User> {
        return repository.getUser()
            .take(1)
            .flatMap { (user) -> Observable<User> in
                guard let user = user else {
                    return Observable.error(SessionExpireError())
                }
                
                return Observable.just(user)
        }
    }
}

