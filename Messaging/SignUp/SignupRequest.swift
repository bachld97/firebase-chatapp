struct SignupRequest {
    let username: String
    let password: String
    let fullname: String
    
    func toDictionary() -> [String:Any] {
        return [
            "password" : self.password,
            "full-name" : self.fullname
        ]
    }
    
    func toUser() -> User {
        return User(userId: username, userName: fullname, userAvatarUrl: nil)
    }
}
