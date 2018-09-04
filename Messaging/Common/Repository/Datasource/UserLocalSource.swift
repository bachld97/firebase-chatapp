import RxSwift

protocol UserLocalSource {
    func persistUser(user: User) -> Observable<Bool>
}

class UserLocalSourceFactory {
    public static let sharedInstance: UserLocalSource = UserLocalSourceImpl()
}
