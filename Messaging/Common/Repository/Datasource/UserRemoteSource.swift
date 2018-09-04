import RxSwift

protocol UserRemoteSource {
    func login(request: LoginRequest) -> Observable<User>
}

class UserRemoteSourceFactory {
    public static let sharedInstance = UserFirebaseSource()
}
