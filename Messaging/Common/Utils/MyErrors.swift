class SimpleError : Error { 
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
}

class SessionExpireError : Error {
    
}
