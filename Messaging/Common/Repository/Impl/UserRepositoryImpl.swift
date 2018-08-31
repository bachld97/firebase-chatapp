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
            return Observable.just(nil)
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
