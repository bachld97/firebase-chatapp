struct Message {
    let type: MessageType
    let data: [String : String]
    
    func compareWith(_ m2: Message) -> Bool {
        return Int64(data["at-time"]!)! > Int64(m2.data["at-time"]!)!
    }
}

enum MessageType {
    case text
    case image
}
