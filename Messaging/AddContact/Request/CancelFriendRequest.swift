struct CancelFriendRequest {
    let canceledContact: Contact
    
    init(canceledContact: Contact) {
        self.canceledContact = canceledContact
    }
}

