final class Conversation {
    let id: String
    let type: ConvoType
    let lastMess: Message
    let nickname: [String: String]
    let displayAva: String?
    let fromMe: Bool
    let myId: String

    init(id: String,
         type: ConvoType,
         lastMess: Message,
         nickname: [String : String],
         displayAva: String?,
         fromMe: Bool,
         myId: String) {
        self.id = id
        self.type = type
        self.lastMess = lastMess
        self.nickname = nickname
        self.displayAva = displayAva
        self.fromMe = fromMe
        self.myId = myId
    }
    
    func compareWith(_ c2: Conversation) -> Bool {
        return self.lastMess.atTimeAsNum > c2.lastMess.atTimeAsNum
    }
}

enum ConvoType {
    case single
    case group
}

