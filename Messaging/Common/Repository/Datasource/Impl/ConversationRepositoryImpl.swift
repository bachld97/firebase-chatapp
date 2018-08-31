import RxSwift

class ConversationRepositoryImpl : ConversationRepository {
    private let userRepository: UserRepository
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func loadChatHistory() -> Observable<[Conversation]?> {
        return Observable.just(nil)
    }
}
