final class Conversation {
    let convoType: ConvoType
    let nicknameDict: [String : String]
    let lastMessDict: [String: String]
    let convoId: String

    init(convoId: String,
         convoType: ConvoType,
         nicknameDict: [String : String],
         lastMessDict: [String: String]) {
        self.convoId = convoId
        self.convoType = convoType
        self.nicknameDict = nicknameDict
        self.lastMessDict = lastMessDict 
    }
}

enum ConvoType {
    case single
    case group
}

