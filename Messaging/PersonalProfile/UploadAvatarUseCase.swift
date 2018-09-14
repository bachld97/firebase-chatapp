import RxSwift

class UploadAvatarUseCase : UseCase {
    typealias TRequest = UploadAvatarRequest
    typealias TResponse = Bool
    
    let repository: UserRepository
        = UserRepositoryFactory.sharedInstance
    
    func execute(request: UploadAvatarRequest) -> Observable<Bool> {
        return repository.uploadAvatar(request: request)
    }
}
