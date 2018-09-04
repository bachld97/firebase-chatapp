import RxSwift

class UserRepositoryImpl : UserRepository {
    func login(request: LoginRequest) -> Observable<Bool>{
        return Observable.deferred {
            return Observable.just(true)
        }
    }
    
    func signup(request: SignupRequest) -> Observable<Bool> {
        return Observable.deferred {
            return Observable.just(true)
        }
    }
    
    func getUser() -> Observable<User?> {
        return Observable.deferred {
            let sampleUrl = "https://3.img-dpreview.com/files/p/E~TS590x0~articles/8692662059/8283897908.jpeg"
            return Observable.just(User(userId: "111", userName: "Duy Bach", userAvatarUrl: sampleUrl))
        }
    }
    
    func logout() -> Observable<Bool> {
        return Observable.deferred {
            return Observable.just(true)
        }
    }
    
    func autoLogin() -> Observable<Bool> {
        return Observable.deferred {
            return Observable.just(false)
        }
    }
    
    func changePassword(request: ChangePassRequest) -> Observable<Bool> {
        return Observable.deferred {
            return Observable.just(true)
        }
    }
}

//// Test UI for fail login
//class UserRepositoryFailImpl: UserRepository {
//    func login(request: LoginRequest) -> Observable<Bool> {
//        print("DEBUG: \(request.username) \(request.password)")
//        return Observable.just(false)
//    }
//
//    func signup(request: SignupRequest) -> Observable<Bool> {
//        return Observable.just(true)
//    }
//}
