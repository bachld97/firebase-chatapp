final class User {
    let userId: String
    let userName: String
    let userAvatarUrl: String?
    // var contacts: [Contact]
    // var conversations: [Conversation]
    
    init(userId: String, userName: String, userAvatarUrl: String?) {
        self.userId = userId
        self.userName = userName
        self.userAvatarUrl = userAvatarUrl
        // contacts = [Contact]()
    }
    
//    func addContact(contact: Contact) {
//        contacts.append(contact)
//    }
//
//    func addConversation(conversation: Conversation) {
//
//    }
}
