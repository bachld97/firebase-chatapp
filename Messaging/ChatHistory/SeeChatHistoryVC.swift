import UIKit
import RxSwift
import RxDataSources
import RxCocoa

class SeeChatHistoryVC: BaseVC, ViewFor {
    var viewModel: SeeChatHistoryViewModel!
    private var disposeBag = DisposeBag()
    private var items: RxTableViewSectionedReloadDataSource<SectionModel<String, SeeChatHistoryViewModel.Item>>!
    
    @IBOutlet weak var tableView: UITableView!
    typealias ViewModelType = SeeChatHistoryViewModel
    
    class func instance() -> UIViewController {
        return SeeChatHistoryVC()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.viewModel = SeeChatHistoryViewModel(displayLogic: self)
    }
    
    init() {
        super.init(nibName: "SeeChatHistoryVC", bundle: nil)
        self.viewModel = SeeChatHistoryViewModel(displayLogic: self)
    }

    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Messages"
        let addImg = UIImage(named: "ic_add")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: addImg,
            style: .plain,
            target: nil,
            action: nil)
        
        super.viewDidLoad()
    }

    override func prepareUI() {
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 72
        self.tableView.register(
            UINib(nibName: "SingleConvoCell", bundle: nil),
            forCellReuseIdentifier: "SingleConvoCell")
        
        self.tableView.register(
        UINib(nibName: "GroupConvoCell", bundle: nil),
        forCellReuseIdentifier: "GroupConvoCell")
        
        self.items = RxTableViewSectionedReloadDataSource<SectionModel<String, SeeChatHistoryViewModel.Item>>(configureCell: { (_, tv, ip, item) -> UITableViewCell in
            let convoItem = item.convoItem
            switch item.convoType {
            case .single:
                let cell = tv.dequeueReusableCell(withIdentifier: "SingleConvoCell")
                    as! SingleConvoCell
                cell.bind(convoItem: convoItem)
                return cell
            case .group:
                let cell = tv.dequeueReusableCell(withIdentifier: "GroupConvoCell")
                    as! GroupConvoCell
                cell.bind(convoItem: convoItem)
                return cell
            }
        })
        
        self.tableView.rx.itemSelected.asDriver()
            .drive(onNext: { [unowned self] (ip) in
                self.tableView.deselectRow(at: ip, animated: false)
                let item = self.items.sectionModels[0].items[ip.row]
                self.goConversation(item: item.convoItem)
            })
            .disposed(by: self.disposeBag)
    }
    
    override func bindViewModel() {
        let viewWillAppear = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = SeeChatHistoryViewModel.Input(
            trigger: viewWillAppear)

        let output = self.viewModel.transform(input: input)
        
        output.error
            .drive(onNext: { [unowned self] (error) in
                self.handleError(e: error)
            })
            .disposed(by: self.disposeBag)
        
        output.items
            .map { [SectionModel(model: "Items", items: $0)]}
            .drive (self.tableView.rx.items(dataSource: self.items))
            .disposed(by: self.disposeBag)
    }
}

extension SeeChatHistoryVC: SeeChatHistoryDisplayLogic {
    func goConversation(item: ConversationItem) {
        let vc = SeeConversationVC.instance(conversationItem: item)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
        // let nc = UINavigationController(rootViewController: vc)
        
        // present(nc, animated: true, completion: nil)
    }
    
    func showEmpty() {
    }
}
