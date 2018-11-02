/*
 * UseCase is a protocol and lives inside the ViewModel
 * Represent our business logic, like SendMessageUseCase,
 * ChangePasswordUseCase, etc.
 * Should be subclassed for each screen / usecase
 */

import RxSwift

public protocol UseCase {
    associatedtype TRequest
    associatedtype TResponse
    
    func execute(request: TRequest) -> Observable<TResponse>
}
