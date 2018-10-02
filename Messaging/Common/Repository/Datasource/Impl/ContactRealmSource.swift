import RxSwift

class ContactRealmSource : ContactLocalSource {
    func persistContacts(contacts: [Contact]) -> Observable<Bool> {
        return Observable.just(true)
    }
    
    func loadContacts(of user: User) -> Observable<[Contact]> {
        var contacts = [Contact]()
        
        let sampleUrl1 = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/Mars_sample_returnjpl.jpg/220px-Mars_sample_returnjpl.jpg"
        let sampleUrl2 = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT73Bt1VGbIq3XTzHyh-C4As0qjcYJgpjSugfCNpZIrxDwr2g2S"
        
        contacts.append(Contact(userId: "ldbach", userName: "Bach Le", userAvatarUrl: sampleUrl1))
        contacts.append(Contact(userId: "hello", userName: "Loo Hee", userAvatarUrl: nil))
        contacts.append(Contact(userId: "aaa22", userName: "Um hum", userAvatarUrl: sampleUrl2))
        return Observable.just(contacts)
    }
    
}
