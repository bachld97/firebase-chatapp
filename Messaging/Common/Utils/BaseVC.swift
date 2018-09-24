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
        } else if e is SessionExpireError {
            self.logoutWithSessionExpire()
        } else {
            print("Unknown error: \(e)")
        }
    }
    
    final func logoutWithSessionExpire() {
        let alertController = UIAlertController(
            title: "Session expired",
            message: "The current session is expired, please login again. Sorry for this inconvenience.",
            preferredStyle: .alert)
        let defaultAction = UIAlertAction(
            title: "Logout",
            style: .cancel,
            handler: { [unowned self] (_) in
                self.doLogout()
        })
        
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    final func logoutNormally() {
        let alertController = UIAlertController(
            title: "Logging out",
            message: "You will not receive notification for incoming messages if you logout. Are you sure to proceed?",
            preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(
            title: "Logout",
            style: .default,
            handler: { [unowned self] (_) in
                self.doLogout()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                          style: .cancel,
                                          handler: nil)
        
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func doLogout() {
        let vc = LoginVC.instance()
        let nc = UINavigationController(rootViewController: vc)
        AppDelegate.sharedInstance.window?.rootViewController = nc
    }
    
    final func goToMainScreen() {
        let vc = MainVC.instance()
        AppDelegate.sharedInstance.window?.rootViewController = vc
    }
}
