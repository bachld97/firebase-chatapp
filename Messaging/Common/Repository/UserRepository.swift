import RxSwift

protocol UserRepository {
    func login(request: LoginRequest) -> Observable<Bool>
    func signup(request: SignupRequest) -> Observable<Bool>
}

class UserRepositoryFactory {
    public static let sharedInstance = UserRepositoryImpl()
}
