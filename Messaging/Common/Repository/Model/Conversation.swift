final class Conversation {
    let id: String
    let type: ConvoType
    let lastMess: Message
    let nickname: [String: String]
    let displayAva: String?

    init(id: String,
         type: ConvoType,
         lastMess: Message,
         nickname: [String : String],
         displayAva: String?) {
        self.id = id
        self.type = type
        self.lastMess = lastMess
        self.nickname = nickname
        self.displayAva = displayAva
    }
}

enum ConvoType {
    case single
    case group
}

