import RxSwift

protocol UserLocalSource {
    func persistUser(user: User) -> Observable<Bool>
    func getUser() -> Observable<User?>
}

class UserLocalSourceFactory {
    public static let sharedInstance: UserLocalSource = UserLocalSourceImpl()
}
