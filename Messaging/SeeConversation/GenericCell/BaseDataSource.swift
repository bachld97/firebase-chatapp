import UIKit

final class BaseDatasource<V, M> : NSObject, UITableViewDataSource where V: BaseCell<M> {
    private var items: [M]
    
    typealias CellConfiguration = (V, M) -> V
    private let configureCell: CellConfiguration
    
    typealias IdentifierGetter = (M) -> String
    private let getReuseIdentifier: IdentifierGetter?
    
    init(items: [M], configureCell: @escaping CellConfiguration, getReuseIdentifier: IdentifierGetter? = nil) {
        self.items = items
        self.configureCell = configureCell
        self.getReuseIdentifier = getReuseIdentifier
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func updateItem(_ items: [M]) {
        self.items = items
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = getIdentifier(forItemAt: indexPath)
        let cell: V = tableView.dequeueCell(withIdentifier: reuseId, forIndexPath: indexPath)
        let item = getItem(at: indexPath)
        return configureCell(cell, item)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    private func getItem(at indexPath: IndexPath) -> M {
        return items[indexPath.item]
    }
    
    private func getIdentifier(forItemAt indexPath: IndexPath) -> String {
        return getReuseIdentifier?(items[indexPath.item]) ?? V.reuseIdentifier
    }
}

