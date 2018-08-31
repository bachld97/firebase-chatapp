import RxSwift

class ChangePassUseCase: UseCase {
    typealias TRequest = ChangePassRequest
    typealias Tresponse = Bool
    
    private let repository: UserRepository = UserRepositoryFactory.sharedInstance
    
    func execute(request: ChangePassRequest) -> Observable<Bool> {
        return repository
            .changePassword(request: request)
    }
}
