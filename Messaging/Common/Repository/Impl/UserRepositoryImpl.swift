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
        return Observable.deferred { [unowned self] in
            return self.remoteSource
                .login(request: request)
                .flatMap { [unowned self] (user) -> Observable<Bool> in
                    return self.localSource
                        .persistUser(user: user)
            }
        }
    }
    
    func signup(request: SignupRequest) -> Observable<Bool> {
        return Observable.deferred { [unowned self] in
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
        return Observable.deferred { [unowned self] in
            return self.localSource.removeUser()
        }
    }
    
    func autoLogin() -> Observable<Bool> {
        return Observable.deferred { [unowned self] in
            return self.localSource
                .getUser()
                .take(1)
                .flatMap { (user) -> Observable<Bool> in
                    return Observable.just(user != nil)
            }
        }
    }
    
    func changePassword(request: ChangePassRequest) -> Observable<Bool> {
        return Observable.deferred { [unowned self] in
            return self.localSource
                .getUser()
                .take(1)
                .flatMap { [unowned self] (user) -> Observable<Bool> in
                    guard let user = user else {
                        return Observable.error(SessionExpireError())
                    }
                    return self.remoteSource.changePassword(of: user, request: request)
            }
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
