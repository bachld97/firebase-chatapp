import RxSwift

class DownloadFileUseCase : UseCase {
    typealias TRequest = DownloadFileRequest
    typealias TResponse = String
    
    private let repository: ConversationRepository
        = ConversationRepositoryFactory.sharedInstance
    
    func execute(request: DownloadFileRequest) -> Observable<String> {
        let messageId = request.messageId
        let fileName = request.fileName
        return repository.downloadFile(messageId: messageId, fileName: fileName)
    }
}
