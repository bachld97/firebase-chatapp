import RxSwift
import FirebaseDatabase

class ContactFirebaseSource: ContactRemoteSource {
    var ref: DatabaseReference!
    
    init() {
        ref = Database.database().reference()
    }
    
    
    func loadContacts(of user: User) -> Observable<[Contact]?> {
        // Go into contacts, see all contact with accepted state
        return Observable.create { [unowned self] (observer) in
            let dbRequest = self.ref.child("contacts").observe(.value, with: { (snapshot) in
                if !snapshot.exists() || !snapshot.hasChild(user.userId) {
                    observer.onNext([])
                    observer.onCompleted()
                }
                
                var res = [String]()
                if let contactDict = snapshot.childSnapshot(forPath: user.userId).value as? [String : String] {
                    contactDict.forEach { (key, value) in
                        if (value.elementsEqual("accepted")) {
                            res.append(key)
                        }
                    }
                }
                observer.onNext(res)
                observer.onCompleted()
            })
            
            return Disposables.create {
                self.ref.removeObserver(withHandle: dbRequest)
            }
            }.flatMap { [unowned self] (userIds) -> Observable<[Contact]?> in
                return self.loadContactDetail(userIds: userIds)
        }
    }
    
    func loadContactDetail(userIds: [String]) -> Observable<[Contact]?> {
        return Observable.create { [unowned self] (observer) in
            let dbRequest = self.ref.child("users").observe(.value, with: { (snapshot) in
                var res = [Contact]()
                (snapshot.value as? [String: Any])?.forEach { (key, value) in
                    if userIds.contains(key) {
                        if let contactDict = value as? [String : String] {
                            let contactName = contactDict["full-name"]!
                            let ava = contactDict["ava-url"]
                            res.append(Contact(userId: key, userName: contactName, userAvatarUrl: ava))
                        }
                    }
                }
                
                observer.onNext(res)
                observer.onCompleted()
            })
            
            return Disposables.create {
                self.ref.removeObserver(withHandle: dbRequest)
            }
        }
    }
    
    func loadUsers(idContains: String) -> Observable<[Contact]> {
        // Go into users, filter keys
        return Observable.create { [unowned self] (observer) in
            
            return Disposables.create {
                
            }
        }
    }
    
    func determineRelation(contacts: [Contact]) -> Observable<[ContactRequest]> {
        // Go into contacts and do some magic
        return Observable.create { [unowned self] (observer) in
            
            return Disposables.create {
                
            }
        }
    }
}
