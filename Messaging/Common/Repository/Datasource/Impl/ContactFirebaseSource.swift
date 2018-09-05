import RxSwift
import FirebaseDatabase

class ContactFirebaseSource: ContactRemoteSource {

    var ref: DatabaseReference!
    
    init() {
        ref = Database.database().reference()
    }
    
    
    func loadContacts(of user: User) -> Observable<[Contact]> {
        // Go into contacts, see all contact with accepted state
        return Observable.create { [unowned self] (observer) in
            let dbRequest = self.ref.child("contacts").observe(.value, with: { (snapshot) in
                guard snapshot.exists() && snapshot.hasChild(user.userId) else {
                    observer.onNext([])
                    observer.onCompleted()
                    return
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
            }) { (error) in
                observer.onError(error)
            }
            
            return Disposables.create {
                self.ref.removeObserver(withHandle: dbRequest)
            }
            }.flatMap { [unowned self] (userIds) -> Observable<[Contact]> in
                return self.loadContactDetail(userIds: userIds)
        }
    }
    
    func loadContactDetail(userIds: [String]) -> Observable<[Contact]> {
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
            }) { (error) in
                observer.onError(error)
            }
            
            return Disposables.create {
                self.ref.removeObserver(withHandle: dbRequest)
            }
        }
    }
    
    func loadUsers(of user: User, idContains: String) -> Observable<[Contact]> {
        // Go into users, filter keys
        return Observable.create { [unowned self] (observer) in
            let dbRequest = self.ref.child("users").observe(.value, with: { (snapshot) in
                guard snapshot.exists() else {
                    observer.onNext([])
                    observer.onCompleted()
                    return
                }
                
                var res = [String]()
                if let contactDict = snapshot.value as? [String : Any] {
                    contactDict.forEach { (key, value) in
                        if !key.elementsEqual(user.userId)
                            && (key.lowercased().contains(idContains.lowercased()) || idContains.isEmpty) {
                            res.append(key)
                        } else if let value = value as? [String : String] {
                            if !key.elementsEqual(user.userId) && value["full-name"]?.lowercased()
                                .contains(idContains.lowercased()) ?? false {
                                res.append(key)
                            }
                        }
                    }
                }
                observer.onNext(res)
                observer.onCompleted()
            }) { (error) in
                observer.onError(error)
            }
            
            return Disposables.create {
                self.ref.child("users").removeObserver(withHandle: dbRequest)
            }
            }.flatMap { [unowned self] (userIds) -> Observable<[Contact]> in
                return self.loadContactDetail(userIds: userIds)
        }
    }
    
    func determineRelation(of user: User, withEach contacts: [Contact]) -> Observable<[ContactRequest]> {
        // Go into contacts and do some magic
        return Observable.create { [unowned self] (observer) in
            
            let dbRequest = self.ref.child("contacts/\(user.userId)").observe(.value, with: { (snapshot) in
                // For each of the contact in contacts[], try to use snapshot to determine the type
                let res = contacts.map { (contact) -> ContactRequest in
                    if let relation = snapshot.childSnapshot(forPath: contact.userId).value
                        as? String {
                        switch relation {
                        case "accepted":
                            return ContactRequest(contact: contact, relation: .accepted)
                        case "requested":
                            return ContactRequest(contact: contact, relation: .requested)
                        case "requesting":
                            return ContactRequest(contact: contact, relation: .requesting)
                        default:
                            return ContactRequest(contact: contact, relation: .stranger)
                        }
                    }
                    return ContactRequest(contact: contact, relation: .stranger)
                }
                
                observer.onNext(res)
                observer.onCompleted()
            }) { (error) in
                observer.onError(error)
            }
            
            return Disposables.create {
                self.ref.child("contacts/\(user.userId)")
                    .removeObserver(withHandle: dbRequest)
            }
        }
    }
}
