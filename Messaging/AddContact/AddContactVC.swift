import RxSwift
import UIKit
import RxCocoa
import RxDataSources

class AddContactVC: BaseVC, ViewFor {
    var viewModel: AddContactViewModel!
    
    typealias ViewModelType = AddContactViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchQueryTF: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var items: RxTableViewSectionedReloadDataSource<SectionModel<String, AddContactViewModel.Item>>!
    
    class func instance() -> UIViewController {
        return AddContactVC()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.viewModel = AddContactViewModel(displayLogic: self)
    }
    
    init() {
        super.init(nibName: "AddContactVC", bundle: nil)
        self.viewModel = AddContactViewModel(displayLogic: self)
    }
    
    override func prepareUI() {
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 90

        self.tableView.register(
            UINib(nibName: "AcceptedContactCell", bundle: nil),
            forCellReuseIdentifier: "AcceptedContactCell")
        
        self.tableView.register(
            UINib(nibName: "RequestingContactCell", bundle: nil),
            forCellReuseIdentifier: "RequestingContactCell")
        
        self.tableView.register(
            UINib(nibName: "StrangerContactCell", bundle: nil),
            forCellReuseIdentifier: "StrangerContactCell")
        
        self.tableView.register(
            UINib(nibName: "RequestedContactCell", bundle: nil),
            forCellReuseIdentifier: "RequestedContactCell")
        
        self.items = RxTableViewSectionedReloadDataSource<SectionModel<String, AddContactViewModel.Item>>(configureCell: { (_, tv, ip, item) -> UITableViewCell in
            switch item {
            case .accepted(let contactItem):
                let cell = tv.dequeueReusableCell(withIdentifier: "AcceptedContactCell")
                    as! AcceptedContactCell
                cell.bind(item: contactItem)
                return cell
                
            case .requested(let contactItem):
                let cell = tv.dequeueReusableCell(withIdentifier: "RequestedContactCell")
                    as! RequestedContactCell
                cell.bind(item: contactItem)
                return cell
                
            case .requesting(let contactItem):
                let cell = tv.dequeueReusableCell(withIdentifier: "RequestingContactCell")
                    as! RequestingContactCell
                cell.bind(item: contactItem)
                return cell
                
            case .stranger(let contactItem):
                let cell = tv.dequeueReusableCell(withIdentifier: "StrangerContactCell")
                    as! StrangerContactCell
                cell.bind(item: contactItem)
                return cell
            }
        })
    }
    
    override func bindViewModel() {
        let viewWillAppear = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = AddContactViewModel.Input(
            trigger: viewWillAppear,
            goBackTrigger: self.backButton.rx.tap.asDriver(),
            searchQuery: self.searchQueryTF.rx.text.orEmpty,
            searchTrigger: self.searchButton.rx.tap.asDriver())
        
        let output = self.viewModel.transform(input: input)
        
        output.items
            .map { [SectionModel(model: "Items", items: $0)]}
            .drive (self.tableView.rx.items(dataSource: self.items))
            .disposed(by: self.disposeBag)
        
        output.error
            .drive(onNext: { [unowned self] (error) in
                self.handleError(e: error)
            })
            .disposed(by: self.disposeBag)
    }
}

extension AddContactVC : AddContactDisplayLogic {
    func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func hideKeyboard() {
        self.view.resignFirstResponder()
    }
}

