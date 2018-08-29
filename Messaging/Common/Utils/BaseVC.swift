/*
 * BaseViewController is the base class for any
 * ViewController in our application
 * Right now it is not so useful, but maybe it is needed later
 */
import UIKit
import Toast

class BaseVC : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        bindViewModel()
    }
    
    open func prepareUI() { }
    
    open func bindViewModel() { }
    
    open func handleError(e: Error) {
        if let error = e as? SimpleError {
            self.view.makeToast(error.message, duration: 3.0, position: CSToastPositionCenter)
        }
    }
}
