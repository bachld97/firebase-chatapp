import RxSwift

protocol ConversationLocalSource {
    
}

class ConversationLocalSourceFactory {
    public static let sharedInstance: ConversationLocalSource = ConversationLocalSourceImpl()
}

class ConversationLocalSourceImpl: ConversationLocalSource {
    
}
