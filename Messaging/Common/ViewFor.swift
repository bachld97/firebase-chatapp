/*
 * ViewFor is a protocol implemented by ViewControllers,
 * specify a ViewModelDelegate class
 * to serve the logic of the ViewController
 */

public protocol ViewFor {
    associatedtype ViewModelType: ViewModelDelegate
    
    var viewModel: ViewModelType! { get set }
}
