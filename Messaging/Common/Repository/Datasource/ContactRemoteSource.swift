import RxSwift

protocol ContactRemoteSource {
    func loadContacts(of user: User) -> Observable<[Contact]>
    func loadUsers(of user: User, with searchString: String) -> Observable<[Contact]>
    func determineRelation(of user: User, withEach contacts: [Contact]) -> Observable<[ContactRequest]>
    
    func acceptFriendRequest(of user: User, for contact: Contact) ->  Observable<Bool>
    func removeFriendRequest(of user: User, for contact: Contact) ->  Observable<Bool>
    func sendFriendRequest(from user: User, to contact: Contact) ->  Observable<Bool>
    func removeFriend(of user: User, for contact: Contact)  ->  Observable<Bool>
    func loadContact(withId contactId: String) -> Observable<Contact>
    
}

class ContactRemoteSourceFactory {
    public static let sharedInstance: ContactRemoteSource = ContactFirebaseSource()
}
