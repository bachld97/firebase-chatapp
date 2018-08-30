import RxSwift

class ContactRepositoryImpl : ContactRepository {
    private let userRepository: UserRepository
    private let remoteSource: ContactRemoteSource
    private let localSource: ContactLocalSource
    
    init(userRepository: UserRepository,
         remoteSource: ContactRemoteSource,
         localSource: ContactLocalSource) {
        self.userRepository = userRepository
        self.remoteSource = remoteSource
        self.localSource = localSource
    }
    
    func seeContact(request: SeeContactRequest) -> Observable<[Contact]?> {
        return Observable.deferred {
            return self.userRepository
                .getUser()
                .take(1)
                .flatMap { [unowned self] (user) -> Observable<[Contact]?> in
                    guard let user = user else {
                        return Observable.error(SessionExpireError())
                    }
                    // TODO: Merge streams from local and remote, diff them.
                    return self.localSource.loadContacts(of: user)
            }
        }
    }
}
