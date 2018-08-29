import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = LoginVC.instance()
        let nc = UINavigationController(rootViewController: vc)
        AppDelegate.sharedInstance.window?.rootViewController = nc
    }
}

