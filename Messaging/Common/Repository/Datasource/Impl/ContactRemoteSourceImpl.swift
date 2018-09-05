import RxSwift

class ContactRemoteSourceImpl : ContactRemoteSource {
    func loadContacts() -> Observable<[Contact]?> {
        return Observable.just(nil)
    }
    
    func loadUsers(idContains: String) -> Observable<[Contact]> {
        return Observable.deferred {
            return Observable.just([])
        }
    }
    
    func determineRelation(contacts: [Contact]) -> Observable<[ContactRequest]> {
        return Observable.deferred {
            return Observable.just([])
        }
    }
}
