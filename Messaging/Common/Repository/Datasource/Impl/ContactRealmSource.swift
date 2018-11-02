import RxSwift
import RealmSwift

class ContactRealmSource : ContactLocalSource {
    func persistContacts(contacts: [Contact], of user: User) -> Observable<[Contact]> {
        return Observable.deferred {
            let realm = try Realm()
            
            // TODO: Delete all contact of this user first.
            try realm.write {
                let query = realm.objects(ContactRealm.self)
                    .filter("userId == %@", user.userId)
                realm.delete(query)
            }
            
            try contacts.forEach { (contact) in
                try realm.write {
                    realm.add(ContactRealm.from(contact, user: user), update: true)
                }
            }
            return Observable.just(contacts)
        }
    }
    
    func loadContacts(of user: User) -> Observable<[Contact]> {
        return Observable.deferred {
            let realm = try Realm()
            let results = realm.objects(ContactRealm.self)
                .filter("userId == %@", user.userId)
                .sorted(byKeyPath: "contactName")
            return Observable.just(results.map { $0.convert()})
        }
    }
    
}
