import UIKit
import IQKeyboardManagerSwift
import Firebase
import FirebaseDatabase
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    class var sharedInstance: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()
        // Database.database().isPersistenceEnabled = true
        Database.database().reference().keepSynced(false)
        
        // DEVELOP: Write Database to easy-to-access location
        if TARGET_OS_SIMULATOR != 0 {
            Realm.Configuration.defaultConfiguration.fileURL = URL(fileURLWithPath: "/Users/cpu12071/Desktop/RealmDb/Messaging.realm")
        }
        
        return true
    }
}

