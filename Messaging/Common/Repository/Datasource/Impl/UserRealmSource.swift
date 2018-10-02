import RxSwift
import RealmSwift

class UserRealmSource : UserLocalSource {
    var user: User?

    func persistUser(user: User) -> Observable<Bool> {
        return Observable.deferred {
            self.user = user
            let realm = try Realm()
            try realm.write {
                realm.add(UserRealm.from(user, loggedIn: true), update: true)
            }
            return Observable.just(true)
        }
    }
    
    func getUser() -> Observable<User?> {
        if user != nil {
            return Observable.just(user!)
        }
        
        return Observable.deferred { [unowned self] in
            let realm = try Realm()
            let result = realm.objects(UserRealm.self)
                .filter("isLoggedIn == %@", true)
                .first
            self.user = result?.convert()
            return Observable.just(self.user)
        }
    }
    
    func removeUser() -> Observable<Bool> {
        let user = self.user ?? User(userId: "", userName: "", userAvatarUrl: "")
        self.user = nil
        return Observable.deferred {
            let realm = try Realm()
            try realm.write {
                realm.add(UserRealm.from(user, loggedIn: false), update: true)
            }
            return Observable.just(true)
        }
    }
}
