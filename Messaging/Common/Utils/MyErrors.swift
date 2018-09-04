class SimpleError : Error { 
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
}

class SessionExpireError: Error {}
class AccountNotFoundError: Error {}
class WrongLoginInformationError: Error {}
class UnknownError: Error {}
class UsernameAlreadyExistError: Error {}

