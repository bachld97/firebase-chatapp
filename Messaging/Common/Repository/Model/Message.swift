struct Message {
    let type: MessageType
    let data: [String : String]
}

enum MessageType {
    case text
    case image
}
