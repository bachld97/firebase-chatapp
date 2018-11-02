import RxSwift

protocol UserRemoteSource {
    func login(request: LoginRequest) -> Observable<User>
    func signup(request: SignupRequest) -> Observable<User>
    func changePassword(of user: User, request: ChangePassRequest) -> Observable<Bool>
    func uploadAva(of user: User, with url: URL) ->  Observable<Bool>
}

class UserRemoteSourceFactory {
    public static let sharedInstance = UserFirebaseSource()
}
