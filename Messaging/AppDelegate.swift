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
        
        testFirebase()
        
        // DEBUG: Write Database to easy-to-access location
        if TARGET_OS_SIMULATOR != 0 {
            Realm.Configuration.defaultConfiguration.fileURL = URL(fileURLWithPath: "/Users/cpu12071/Desktop/RealmDb/Messaging.realm")
        }
        
        return true
    }
    
    private func testFirebase() {
        let ref = Database.database().reference().child("test")
        ref.runTransactionBlock( { (currentData) -> TransactionResult in
            if !currentData.hasChildren() {
                currentData.value = "test-value4"
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.abort()
            // return TransactionResult.success(withValue: currentData)
        }, andCompletionBlock: { (error, whatBool, snapshot) in
            print("Transaction returned: \(error), \(snapshot?.ref.parent), \(whatBool)")
        }, withLocalEvents: false)
    }
}

