/*
 * ViewModelDelegate is responsible for data binding
 * ControlObservable: Observable control passed to ViewModel
 * VmObservable: ViewModel's observable fields to update UI
 */
public protocol ViewModelDelegate {
    associatedtype ControlObservable
    associatedtype VmObservable
    
    func transform(input: ControlObservable) -> VmObservable
}
