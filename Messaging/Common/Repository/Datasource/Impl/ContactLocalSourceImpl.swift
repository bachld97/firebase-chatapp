import RxSwift

class ContactLocalSourceImpl : ContactLocalSource {
    func persistContacts(contacts: [Contact]) -> Observable<Bool> {
        return Observable.just(true)
    }
    
    func loadContacts(of user: User) -> Observable<[Contact]?> {
        var contacts = [Contact]()
        contacts.append(Contact(userId: "ldbach", userName: "Bach Le", userAvatarUrl: nil))
        contacts.append(Contact(userId: "hello", userName: "Loo Hee", userAvatarUrl: nil))
        contacts.append(Contact(userId: "aaa22", userName: "Um hum", userAvatarUrl: nil))
        return Observable.just(contacts)
    }
    
}
