import RxSwift

class UserRepositoryImpl : UserRepository {
    
    private let localSource: UserLocalSource
    private let remoteSource: UserRemoteSource
    
    init(localSource: UserLocalSource,
         remoteSource: UserRemoteSource) {
        self.localSource = localSource
        self.remoteSource = remoteSource
    }

    func login(request: LoginRequest) -> Observable<Bool>{
        return Observable.deferred {
            return self.remoteSource
                .login(request: request)
                .flatMap { [unowned self] (user) -> Observable<Bool> in
                    return self.localSource
                        .persistUser(user: user)
            }
        }
    }
    
    func signup(request: SignupRequest) -> Observable<Bool> {
        return Observable.deferred {
            return self.remoteSource
                .signup(request: request)
                .flatMap { [unowned self] (user) -> Observable<Bool> in
                    return self.localSource
                        .persistUser(user: user)
            }
        }
    }
    
    func getUser() -> Observable<User?> {
        return Observable.deferred {
            return self.localSource.getUser()
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
