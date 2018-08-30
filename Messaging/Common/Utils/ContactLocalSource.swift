import RxSwift

protocol ContactLocalSource {
    func persistContacts(contacts: [Contact]) -> Observable<Bool>
    func loadContacts(of user: User) -> Observable<[Contact]?>
}

class ContactLocalSourceFactory {
    static let sharedInstance: ContactLocalSource = ContactLocalSourceImpl()
}
