import RxSwift

class AddContactUseCase: UseCase {
    typealias TRequest = AddContactRequest
    typealias TResponse = Bool
    
    func execute(request: AddContactRequest) -> Observable<Bool> {
        return Observable.just(true)
    }
}
