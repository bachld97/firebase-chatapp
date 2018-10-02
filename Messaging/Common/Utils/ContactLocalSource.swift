import RxSwift

protocol ContactLocalSource {
    func persistContacts(contacts: [Contact], of user: User) -> Observable<[Contact]>
    func loadContacts(of user: User) -> Observable<[Contact]>
}

class ContactLocalSourceFactory {
    static let sharedInstance: ContactLocalSource = ContactRealmSource()
}
