import RxSwift

protocol ContactRemoteSource {
   func loadContacts() -> Observable<[Contact]?>
}

class ContactRemoteSourceFactory {
    public static let sharedInstance: ContactRemoteSource = ContactRemoteSourceImpl()
}
