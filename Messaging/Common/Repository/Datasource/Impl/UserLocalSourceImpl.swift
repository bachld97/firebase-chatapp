import RxSwift

class UserLocalSourceImpl : UserLocalSource {
    func persistUser(user: User) -> Observable<Bool> {
        return Observable.just(true)
    }
}
