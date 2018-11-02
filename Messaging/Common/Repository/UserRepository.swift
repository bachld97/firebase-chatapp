import RxSwift

protocol UserRepository {
    func login(request: LoginRequest) -> Observable<Bool>
    func signup(request: SignupRequest) -> Observable<Bool>
    func getUser() -> Observable<User?>
    func logout() -> Observable<Bool>
    func autoLogin() -> Observable<Bool>
    func changePassword(request: ChangePassRequest) -> Observable<Bool>
    func uploadAvatar(request: UploadAvatarRequest) -> Observable<Bool>
} 

class UserRepositoryFactory {
    public static let sharedInstance = UserRepositoryImpl(
        localSource: UserLocalSourceFactory.sharedInstance,
        remoteSource: UserRemoteSourceFactory.sharedInstance)
}
