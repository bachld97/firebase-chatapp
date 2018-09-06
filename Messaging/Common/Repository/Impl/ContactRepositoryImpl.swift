import RxSwift

class ContactRepositoryImpl : ContactRepository {

    private let userRepository: UserRepository
    private let remoteSource: ContactRemoteSource
    private let localSource: ContactLocalSource
    
    func acceptRequest(request: AcceptFriendRequest) -> Observable<Bool> {
        fatalError("Not implemented")
    }
    
    func cancelFriendRequest(request: CancelFriendRequest) -> Observable<Bool> {
        fatalError("Not implemented")
    }
    
    func addFriendRequest(request: AddFriendRequest) -> Observable<Bool> {
        fatalError("Not implemented")
    }
    
    func unfriendRequest(request: UnfriendRequest) -> Observable<Bool> {
        fatalError("Not implemented")
    }
    
    init(userRepository: UserRepository,
         remoteSource: ContactRemoteSource,
         localSource: ContactLocalSource) {
        self.userRepository = userRepository
        self.remoteSource = remoteSource
        self.localSource = localSource
    }
    
    func seeContact() -> Observable<[Contact]> {
        return Observable.deferred {
            return self.userRepository
                .getUser()
                .take(1)
                .flatMap { [unowned self] (user) -> Observable<[Contact]> in
                    guard let user = user else {
                        return Observable.error(SessionExpireError())
                    }
                    // TODO: Merge streams from local and remote, diff them.
                    return self.remoteSource.loadContacts(of: user)
                    // return self.localSource.loadContacts(of: user)
            }
        }
    }
    
    func searchContact(request: SearchContactRequest) -> Observable<[ContactRequest]> {
        return Observable.deferred {
            return self.userRepository
                .getUser()
                .take(1)
                .flatMap { [unowned self] (user) -> Observable<[ContactRequest]> in
                    guard let user = user else {
                        return Observable.error(SessionExpireError())
                    }
                    
                    return self.remoteSource.loadUsers(of: user, with: request.searchString)
                        .flatMap { [unowned self] (contacts) in
                            return self.remoteSource.determineRelation(of: user, withEach: contacts)
                    }
            }
        }
    }
}
