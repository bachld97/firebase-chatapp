final class Conversation {
    let id: String
    let type: ConvoType
    let lastMess: Message
    let nickname: [String: String]
    let lastSeen: [String: Int64]
    
    let displayAva: String?
    let fromMe: Bool
    let myId: String

    init(id: String,
         type: ConvoType,
         lastMess: Message,
         nickname: [String : String],
         displayAva: String?,
         fromMe: Bool,
         myId: String,
         lastSeen: [String: Int64]) {
        self.id = id
        self.type = type
        self.lastMess = lastMess
        self.nickname = nickname
        self.displayAva = displayAva
        self.fromMe = fromMe
        self.myId = myId
        self.lastSeen = lastSeen
    }
    
    func compareWith(_ c2: Conversation) -> Bool {
        return self.lastMess.atTimeAsNum > c2.lastMess.atTimeAsNum
    }
    
    func replaceLastMessage(with mess: Message) -> Conversation {
        return Conversation(id: self.id,
                            type: self.type, lastMess: mess,
                            nickname: self.nickname, displayAva: self.displayAva,
                            fromMe: self.fromMe, myId: self.myId, lastSeen: self.lastSeen)
    }
}

enum ConvoType {
    case single
    case group
}

