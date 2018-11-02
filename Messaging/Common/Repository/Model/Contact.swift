final class Contact {
    let userId: String
    let userName: String
    let userAvatarUrl: String?
    
    init(userId: String, userName: String, userAvatarUrl: String?) {
        self.userId = userId
        self.userName = userName
        self.userAvatarUrl = userAvatarUrl
    }
    
    func compareWith(_ contact: Contact) -> Bool {
        return self.userName.uppercased() < contact.userName.uppercased()
    }
}
