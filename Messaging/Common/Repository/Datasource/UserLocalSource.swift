import RxSwift

protocol UserLocalSource {
    func persistUser(user: User) -> Observable<Bool>
    func getUser() -> Observable<User?>
    func removeUser() -> Observable<Bool>
}

class UserLocalSourceFactory {
    public static let sharedInstance: UserLocalSource = UserLocalSourceImpl()
}
