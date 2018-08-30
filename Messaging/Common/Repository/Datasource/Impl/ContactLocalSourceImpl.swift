import RxSwift

class ContactLocalSourceImpl : ContactLocalSource {
    func persistContacts(contacts: [Contact]) -> Observable<Bool> {
        return Observable.just(true)
    }
    
    func loadContacts(of user: User) -> Observable<[Contact]?> {
        return Observable.just(nil)
    }
    
    
}
