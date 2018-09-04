import RxSwift

protocol UserRemoteSource {
    func login(request: LoginRequest) -> Observable<User>
    func signup(request: SignupRequest) -> Observable<User>
}

class UserRemoteSourceFactory {
    public static let sharedInstance = UserFirebaseSource()
}
