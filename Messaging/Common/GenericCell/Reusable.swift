import UIKit

protocol Reusable {}

extension Reusable where Self: UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: Reusable {}

extension UITableView {
    func register<V: UITableViewCell>(_ : V.Type) {
        self.register(V.self, forCellReuseIdentifier: V.reuseIdentifier)
    }
    
    func dequeueCell<V: UITableViewCell>(withIdentifier reuseId: String, forIndexPath: IndexPath) -> V {
        guard let cell = self.dequeueReusableCell(withIdentifier: reuseId, for: forIndexPath) as? V else {
            fatalError("Cannot dequeu cell with identifier: \(V.reuseIdentifier)")
        }
        
        return cell
    }
}
