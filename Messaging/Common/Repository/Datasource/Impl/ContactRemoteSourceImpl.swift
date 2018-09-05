import RxSwift

class ContactRemoteSourceImpl : ContactRemoteSource {
    func loadContacts() -> Observable<[Contact]?> {
        return Observable.just(nil)
    }
    
    func loadUsers(idContains: String) -> Observable<[Contact]> {
        return Observable.deferred {
            return Observable.just([])
        }
    }
    
    func determineRelation(contacts: [Contact]) -> Observable<[ContactRequest]> {
        return Observable.deferred {
            let sampleUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/Mars_sample_returnjpl.jpg/220px-Mars_sample_returnjpl.jpg"
            let contact = Contact(userId: "bachld10832", userName: "Le Duy Bach", userAvatarUrl: sampleUrl)
            let item1 = ContactRequest(contact: contact, relation: .requesting)
            let item2 = ContactRequest(contact: contact, relation: .requested)
            let item3 = ContactRequest(contact: contact, relation: .accepted)
            let item4 = ContactRequest(contact: contact, relation: .stranger)
            var items = [ContactRequest]()
            items.append(item1)
            items.append(item2)
            items.append(item3)
            items.append(item4)
            return Observable.just(items)
        }
    }
}
