class SimpleError : Error { 
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
}

class EmptyQueryError: Error {}

class SessionExpireError: Error {}

class AccountNotFoundError: SimpleError {
    init() {
        super.init(message: "Account not found. Please check your login information and try again.")
    }
}

class WrongOldPasswordError: SimpleError {
    init() {
        super.init(message: "Change password failed. The password you entered is not correct.")
    }
}

class WrongLoginInformationError: SimpleError {
    init() {
        super.init(message: "The password you entered is not correct. Please check your login information and try again.")
    }
}

class UnknownError: SimpleError {
    init() {
        super.init(message: "We are doing application maintainence. Please login later.")
    }
}

class UsernameAlreadyExistError: SimpleError {
    init() {
        super.init(message: "You cannot create account with this username. It is already taken!")
    }
}


