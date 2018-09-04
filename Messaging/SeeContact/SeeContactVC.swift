import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SeeContactVC: BaseVC, ViewFor {
    class func instance() -> UIViewController {
        return SeeContactVC()
    }
    
    @IBOutlet weak var contactTableView: UITableView!
    public typealias ViewModelType = SeeContactViewModel
    var viewModel: SeeContactViewModel!
    private var items : RxTableViewSectionedReloadDataSource<SectionModel<String, ContactItem>>!
    
    private let disposeBag = DisposeBag()
    
    init() {
        super.init(nibName: "SeeContactVC", bundle: nil)
        self.viewModel = SeeContactViewModel(displayLogic: self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.viewModel = SeeContactViewModel(displayLogic: self)
    }

    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Contacts"
        
        let retryImg = UIImage(named: "ic_reload")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: retryImg,
                                                                 style: .plain,
                                                                 target: nil,
                                                                 action: nil)
        super.viewDidLoad()
    }
    
    override func bindViewModel() {
        let viewWillAppear = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = SeeContactViewModel.Input(
                trigger: viewWillAppear,
                reloadTrigger: self.navigationItem.rightBarButtonItem!.rx.tap.asDriver())
        
        
        
        let output = viewModel.transform(input: input)
        
        output.error.drive(onNext: { [unowned self] (error) in
            self.handleError(e: error)
        }).disposed(by: self.disposeBag)
        
        output.items
            .map { [SectionModel(model: "Items", items: $0)]}
            .drive(self.contactTableView.rx.items(dataSource: self.items))
            .disposed(by: self.disposeBag)
    }
    
    override func prepareUI() {
        self.contactTableView.tableFooterView = UIView()
        self.contactTableView.rowHeight = UITableViewAutomaticDimension
        self.contactTableView.estimatedRowHeight = 72
        self.contactTableView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "ContactCell")
        self.items = RxTableViewSectionedReloadDataSource<SectionModel<String, ContactItem>>(configureCell: { (_, tv, ip, item) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "ContactCell", for: ip) as! ContactCell
            cell.bind(item: item)
            return cell
        })
        
        // Set up click
        self.contactTableView.rx.itemSelected.asDriver()
            .drive(onNext: { (ip) in
                self.contactTableView.deselectRow(at: ip, animated: false)
                let item = self.items.sectionModels[0].items[ip.row]
                self.goConversation(item)
            })
            .disposed(by: self.disposeBag)
    }
}

extension SeeContactVC : SeeContactDisplayLogic {
    func goConversation(_ item: ContactItem) {
        let vc = SeeConversationVC.instance(contactItem: item)
        present(vc, animated: true, completion: nil)
        // self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showEmpty() {
        print("Empty")
    }
}
