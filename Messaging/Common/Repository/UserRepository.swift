import RxSwift

protocol UserRepository {
    func login(request: LoginRequest) -> Observable<Bool>
    func signup(request: SignupRequest) -> Observable<Bool>
    func getUser() -> Observable<User?>
    func logout() -> Observable<Bool>
    func autoLogin() -> Observable<Bool>
} 

class UserRepositoryFactory {
    public static let sharedInstance = UserRepositoryImpl()
}
