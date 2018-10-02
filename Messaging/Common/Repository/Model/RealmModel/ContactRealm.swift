import RealmSwift

class ContactRealm: Object {
    // The database to designed to have only insert(override: true)
    @objc dynamic var id: String = ""
    @objc dynamic var userId: String = ""
    @objc dynamic var contactId: String = ""
    @objc dynamic var contactAva: String = ""
    @objc dynamic var contactName: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func from(_ contact: Contact, user: User) -> ContactRealm {
        let res = ContactRealm()
        res.id = "\(user.userId)\(contact.userId)"
        res.userId = user.userId
        res.contactId = contact.userId
        res.contactAva = contact.userAvatarUrl
            ?? UrlBuilder.buildUrl(forUserId: contact.userId)
        res.contactName = contact.userName
        return res
    }
    
    func convert() -> Contact {
       return Contact(userId: contactId,
                      userName: contactName,
                      userAvatarUrl: contactAva)
    }
}
