import RxSwift

class ContactRemoteSourceImpl : ContactRemoteSource {
    func loadContacts() -> Observable<[Contact]?> {
        return Observable.just(nil)
    }
}
