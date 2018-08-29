struct SignupRequest {
    let username: String
    let password: String
    let fullname: String
    
    func toDictionary() -> [String:Any] {
        return [
            "username" : self.username,
            "password" : self.password,
            "fullname" : self.fullname
        ]
    }
}
