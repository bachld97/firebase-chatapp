import RxSwift
import FirebaseDatabase

class UserFirebaseSource : UserRemoteSource {
    var ref: DatabaseReference!
    
    init() {
        ref = Database.database().reference()
    }

    func login(request: LoginRequest) -> Observable<User> {
        return Observable.create { [unowned self] (observer) -> Disposable in
            let dbRequest = self.ref.child("users").observe(.value, with: { (snapshot) in
                if !snapshot.exists() || !snapshot.hasChild(request.username) {
                    print("Account not exists")
                    observer.onError(AccountNotFoundError())
                    return
                }
                
                if let userDict = snapshot.childSnapshot(forPath: request.username).value as? [String : String] {
                    let password = userDict["password"]!
                    let fullname = userDict["full-name"]!
                    let ava = userDict["ava-url"]

                    if !request.password.elementsEqual(password) {
                        print("Wrong pass")
                        observer.onError(WrongLoginInformationError())
                        return
                    } else {
                        observer.onNext(User(userId: request.username, userName: fullname, userAvatarUrl: ava))
                        observer.onCompleted()
                        return
                    }
                } else {
                    print("Should never happens")
                    observer.onError(UnknownError())
                }
            })
            
            return Disposables.create {
                self.ref.child("users").removeObserver(withHandle: dbRequest)
            }
        }
    }
}
