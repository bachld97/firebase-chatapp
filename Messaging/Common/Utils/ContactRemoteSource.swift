import RxSwift

protocol ContactRemoteSource {
    func loadContacts(of user: User) -> Observable<[Contact]>
    func loadUsers(of user: User, with searchString: String) -> Observable<[Contact]>
    func determineRelation(of user: User, withEach contacts: [Contact]) -> Observable<[ContactRequest]>
}

class ContactRemoteSourceFactory {
    public static let sharedInstance: ContactRemoteSource = ContactFirebaseSource()
}
