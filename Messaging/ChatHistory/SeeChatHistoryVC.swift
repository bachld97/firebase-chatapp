import UIKit
import RxSwift
import RxDataSources
import RxCocoa
import DeepDiff

class SeeChatHistoryVC: BaseVC, ViewFor {
    var viewModel: SeeChatHistoryViewModel!
    private var disposeBag = DisposeBag()
    
    private let conversationPublisher = PublishSubject<Int>()
    
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
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 72
        registerCells()
        
        self.tableView.rx.itemSelected.asDriver()
            .drive(onNext: { [unowned self] (ip) in
                self.tableView.deselectRow(at: ip, animated: false)
                self.conversationPublisher.onNext(ip.item)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func registerCells() {
        self.tableView?.register(PrivateConversationCell.self)
    }
    
    override func bindViewModel() {
        let viewWillAppear = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = SeeChatHistoryViewModel.Input(
            trigger: viewWillAppear,
            conversationTrigger: conversationPublisher.asDriverOnErrorJustComplete())

        let output = self.viewModel.transform(input: input)
        
        output.error
            .drive(onNext: { [unowned self] (error) in
                self.handleError(e: error)
            })
            .disposed(by: self.disposeBag)
        
        self.tableView.dataSource = output.dataSource
    }
}

extension SeeChatHistoryVC: SeeChatHistoryDisplayLogic {
    func notifyItems(with changes: [Change<ConversationItem>]?) {
       guard changes != nil else {
            self.tableView?.reloadData()
            return
        }
        
        print("-----")
        print(changes)
        self.tableView?.reload(changes: changes!, completion: { (_) in })
    }
    
    func goConversation(item: ConversationItem) {
        let vc = SeeConversationVC.instance(conversationItem: item)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showEmpty() {
    }
}
