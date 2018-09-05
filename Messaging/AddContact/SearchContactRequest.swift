struct SearchContactRequest {
    let usernameContains: String
    
    init(usernameContains: String) {
        self.usernameContains = usernameContains
    }
}
