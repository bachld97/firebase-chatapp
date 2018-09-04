import RxSwift

protocol ContactRepository {
    func seeContact() -> Observable<[Contact]?>
}

class ContactRepositoryFactory {
    public static let sharedInstance = ContactRepositoryImpl(
        userRepository: UserRepositoryFactory.sharedInstance,
        remoteSource: ContactRemoteSourceFactory.sharedInstance,
        localSource: ContactLocalSourceFactory.sharedInstance)
}
