import RealmSwift

class ConversationRealm: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var userId: String = ""
    @objc dynamic var convId: String = ""
    @objc dynamic var isPrivate: Bool = true
    
    // This is a formatted string
    @objc dynamic var nicknames: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func from(_ conversation: Conversation) -> ConversationRealm {
        let conv = ConversationRealm()
        conv.userId = conversation.myId
        conv.id = "\(conversation.id)\(conversation.myId)"
        conv.convId = conversation.id
        conv.isPrivate = (conversation.type == .single)
        conv.nicknames = DictionaryConverter.convert(from: conversation.nickname)
        return conv
    }
}
