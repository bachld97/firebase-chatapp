import RxSwift

protocol ContactRepository {
    func seeContact() -> Observable<[Contact]>
    func searchContact(request: SearchContactRequest) -> Observable<[ContactRequest]>
    func acceptRequest(request: AcceptFriendRequest) -> Observable<Bool>
    func cancelFriendRequest(request: CancelFriendRequest) -> Observable<Bool>
    func addFriendRequest(request: AddFriendRequest) -> Observable<Bool>
    func unfriendRequest(request: UnfriendRequest) -> Observable<Bool>
}

class ContactRepositoryFactory {
    public static let sharedInstance = ContactRepositoryImpl(
        userRepository: UserRepositoryFactory.sharedInstance,
        remoteSource: ContactRemoteSourceFactory.sharedInstance,
        localSource: ContactLocalSourceFactory.sharedInstance)
}
