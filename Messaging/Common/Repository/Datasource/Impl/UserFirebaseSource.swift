import RxSwift
import FirebaseDatabase
import  FirebaseStorage

class UserFirebaseSource : UserRemoteSource {
    var ref: DatabaseReference!
    
    init() {
        ref = Database.database().reference()
    }
    
    func changePassword(of user: User, request: ChangePassRequest) -> Observable<Bool> {
        return Observable.create { [unowned self] (observer) -> Disposable in
            
            let dbRequest = self.ref.child("users/\(user.userId)")
                .observe(.value, with: { (snapshot) in
                    guard (snapshot.childSnapshot(forPath: "password")
                        .value as! String).elementsEqual(request.oldPass) else {
                            observer.onError(WrongOldPasswordError())
                            observer.onCompleted()
                            return
                    }
                    
                    self.ref.child("users/\(user.userId)")
                        .updateChildValues(["password" : request.newPass])
                    
                    observer.onNext(true)
                    observer.onCompleted()
                }) { (error) in
                    observer.onError(error)
            }

            return Disposables.create { [unowned self] in
                self.ref.child("user/\(user.userId)")
                    .removeObserver(withHandle: dbRequest)
            }
        }
    }
    
    private var uploadTask: StorageUploadTask?
    func uploadAva(of user: User, with url: URL) -> Observable<Bool> {
        return Observable.create { [unowned self] (obs) in
            
            let ref = Storage.storage().reference()
                .child("users/\(user.userId)")
            self.uploadTask?.cancel()
            
            self.uploadTask = ref.putFile(from: url, metadata: nil) { metadata, error in
                if error != nil {
                    obs.onError(error!)
                } else {
                    obs.onNext(true)
                }
            }
            return Disposables.create()
        }
    }

    func login(request: LoginRequest) -> Observable<User> {
        return Observable.create { [unowned self] (observer) -> Disposable in
            let dbRequest = self.ref.child("users/\(request.username)").observe(.value, with: { (snapshot) in
                guard snapshot.exists() else {
                    observer.onError(AccountNotFoundError())
                    return
                }
                
                guard let userDict = snapshot.value as? [String : String] else {
                    print("Should never happens")
                    observer.onError(UnknownError())
                    return
                }

                let password = userDict["password"]!
                let fullname = userDict["full-name"]!
                let ava = userDict["ava-url"]
                
                if !request.password.elementsEqual(password) {
                    observer.onError(WrongLoginInformationError())
                    return
                } else {
                    observer.onNext(User(userId: request.username, userName: fullname, userAvatarUrl: ava))
                    observer.onCompleted()
                    return
                }
                
            })
            
            return Disposables.create {
                self.ref.child("users").removeObserver(withHandle: dbRequest)
            }
        }
    }
    
    func signup(request: SignupRequest) -> Observable<User> {
        return Observable.create { [unowned self] (observer) -> Disposable in
            let dbRequest = self.ref.child("users").observe(.value, with: { (snapshot) in
                if !snapshot.exists() || !snapshot.hasChild(request.username) {
                    // Success
                    self.ref.child("users/\(request.username)")
                        .setValue(request.toDictionary())
                    let user = request.toUser()
                    observer.onNext(user)
                    observer.onCompleted()
                } else {
                    observer.onError(UsernameAlreadyExistError())
                }
            })
            
            return Disposables.create {
                self.ref.child("users").removeObserver(withHandle: dbRequest)
            }
        }
    }
}
