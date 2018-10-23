import UIKit
import IQKeyboardManagerSwift
import Firebase
import GoogleMaps
import GooglePlaces
import FirebaseDatabase
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let key = "AIzaSyBaghqgDkJL6IwSOgQA8NqeePDERDP4ml4"
    
    class var sharedInstance: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Keyboard manager
        IQKeyboardManager.shared.enable = true
        
        // Firebase setting
        FirebaseApp.configure()
        Database.database().reference().keepSynced(false)
        
        // Wrtie to temporary location
        if TARGET_OS_SIMULATOR != 0 {
            Realm.Configuration.defaultConfiguration.fileURL = URL(fileURLWithPath: "/Users/cpu12071/Desktop/RealmDb/Messaging.realm")
        }
        
        // GoogleMaps and Places
        GMSServices.provideAPIKey(key)
        GMSPlacesClient.provideAPIKey(key)
        return true
    }
}
