import RxSwift
import RxCocoa

infix operator <->

public func <-> <T>(property: ControlProperty<T>, variable: BehaviorRelay<T>) -> Disposable {
    let bindToUIDisposable = variable.asObservable()
        .bind(to: property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            variable.accept(n)
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })
    
    return Disposables.create(bindToUIDisposable, bindToVariable)
}

public func <-> <T>(property: ControlProperty<T>, variable: PublishRelay<T>) -> Disposable {
    let bindToUIDisposable = variable.asObservable()
        .bind(to: property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            variable.accept(n)
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })
    
    return Disposables.create(bindToUIDisposable, bindToVariable)
}

public func <-> <T : Comparable>(subject: PublishSubject<T>, variable: BehaviorRelay<T>) -> Disposable {
    let bindToUIDisposable = variable.asObservable()
        .bind(to: subject)
    let bindToVariable = subject
        .subscribe(onNext: { n in
            if variable.value != n {
                variable.accept(n)
            }
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })
    
    return Disposables.create(bindToUIDisposable, bindToVariable)
}

public func <-> <T : Comparable>(subject: PublishSubject<T?>, variable: BehaviorRelay<T?>) -> Disposable {
    let bindToUIDisposable = variable.asObservable()
        .bind(to: subject)
    let bindToVariable = subject
        .subscribe(onNext: { n in
            if variable.value != n {
                variable.accept(n)
            }
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })
    
    return Disposables.create(bindToUIDisposable, bindToVariable)
}
