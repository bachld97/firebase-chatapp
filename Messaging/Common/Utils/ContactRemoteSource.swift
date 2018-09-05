import RxSwift

protocol ContactRemoteSource {
    func loadContacts() -> Observable<[Contact]?>
    func loadUsers(idContains: String) -> Observable<[Contact]>
    func determineRelation(contacts: [Contact]) -> Observable<[ContactRequest]>
}

class ContactRemoteSourceFactory {
    public static let sharedInstance: ContactRemoteSource = ContactRemoteSourceImpl()
}
