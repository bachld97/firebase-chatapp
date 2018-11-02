import RxSwift

class GetContactNicknameUseCase: UseCase {
    typealias TRequest = GetContactNickNameRequest
    typealias TResponse = String
    
    private let repository: ConversationRepository
        = ConversationRepositoryFactory.sharedInstance
    
    func execute(request: GetContactNickNameRequest) -> Observable<String> {
        return repository.getContactNickname(contact: request.contact)
    }
}

