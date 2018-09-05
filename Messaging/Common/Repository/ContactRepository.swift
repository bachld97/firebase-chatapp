import RxSwift

protocol ContactRepository {
    func seeContact() -> Observable<[Contact]?>
    func searchContact(request: SearchContactRequest) -> Observable<[ContactRequest]>
}

class ContactRepositoryFactory {
    public static let sharedInstance = ContactRepositoryImpl(
        userRepository: UserRepositoryFactory.sharedInstance,
        remoteSource: ContactRemoteSourceFactory.sharedInstance,
        localSource: ContactLocalSourceFactory.sharedInstance)
}
