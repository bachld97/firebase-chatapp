import RxSwift

protocol ConversationRemoteSource {
    
}

class ConversationRemoteSourceFactory {
    public static let sharedInstance: ConversationRemoteSource = ConversationFirebaseSource()
}
