import UIKit
import RxCocoa
import RxSwift 
import RxDataSources
import DeepDiff

class SeeConversationVC: BaseVC, ViewFor {
    var viewModel: SeeConversationViewModel!
    private let disposeBag = DisposeBag()
    typealias ViewModelType = SeeConversationViewModel
    
    @IBOutlet weak var textMessageContent: UITextField!
    
    @IBOutlet weak var sendImageButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendMessageButton: UIButton!
    
    // private var configurator: MessageCellConfigurator?
    
   
    
    private let sendImagePublish = PublishSubject<URL>()
    
    private let onCreatePublish = PublishSubject<Void>()
    
    private var items: RxTableViewSectionedReloadDataSource
        <SectionModel<String, SeeConversationViewModel.Item>>!
    
    class func instance(contactItem item: ContactItem) -> UIViewController {
        return SeeConversationVC(contactItem: item)
    }
    
    class func instance(conversationItem item: ConversationItem) -> UIViewController {
        return SeeConversationVC(conversationItem: item)
    }
    
//    class func instance(_ item: ChatHistoryItem) -> UIViewController {
//        return SeeConversationVC()
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("Cannot instantiate like this")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
    }
    

    private init(contactItem: ContactItem) {
        super.init(nibName: "SeeConversationVC", bundle: nil)
        self.viewModel = SeeConversationViewModel(
            displayLogic: self,
            contactItem: contactItem)
    }
    
    private init(conversationItem: ConversationItem) {
        super.init(nibName: "SeeConversationVC", bundle: nil)
        self.viewModel = SeeConversationViewModel(displayLogic: self, conversationItem: conversationItem)
    }
    
    override func prepareUI() {
        self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.tableView.tableFooterView = UIView()
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 90
        registerCells()
    }
    
    override func bindViewModel() {
        let input = SeeConversationViewModel.Input(
            trigger: onCreatePublish.asDriverOnErrorJustComplete(),
            sendMessTrigger: self.sendMessageButton.rx.tap.asDriver(),
            conversationLabel: self.navigationItem.rx.title,
            textMessage: self.textMessageContent.rx.text.orEmpty,
            sendImageTrigger: self.sendImageButton.rx.tap.asDriver(),
            sendImagePublish: self.sendImagePublish.asDriverOnErrorJustComplete())
        
        let output = self.viewModel.transform(input: input)
        
        output.error
            .drive(onNext: { [unowned self]  error in
                self.handleError(e: error)
            })
        .disposed(by: self.disposeBag)
        
        self.tableView?.dataSource = output.dataSource
        onCreatePublish.onNext(())
    }
    
    private func registerCells() {
        self.tableView?.register(TextTimeMessageCell.self)
        self.tableView?.register(TextMessageCell.self)
        self.tableView?.register(TextMeTimeMessageCell.self)
        self.tableView?.register(TextMeMessageCell.self)
        
        self.tableView?.register(ImageTimeMessageCell.self)
        self.tableView?.register(ImageMessageCell.self)
        self.tableView?.register(ImageMeTimeMessageCell.self)
        self.tableView?.register(ImageMeMessageCell.self)
    }
}

extension SeeConversationVC : SeeConversationDisplayLogic, PickMediaDelegate {
    func notifyItems(with changes: [Change<MessageItem>]?) {
        guard changes != nil else {
            self.tableView?.reloadData()
            return
        }
        
        self.tableView?.reload(changes: changes!, completion: { (_) in })
    }
    
    func notifyItem(with addRespond: (Bool, Int)) {
        self.tableView?.reloadData()
        
//        if !addRespond.0 {
//            let index = addRespond.1
//            let indexPath = NSIndexPath(row: index, section: 0) as IndexPath
//            self.tableView?.reloadRows(at: [indexPath], with: .automatic)
//
//        } else {
//            let indexPath = NSIndexPath(row: 0, section: 0)
//            self.tableView?.insertItemsAtIndexPaths([indexPath as IndexPath], animationStyle: .bottom)
//            if addRespond.1 == 1 {
//                // There is change in the current first item
//                let indexPath = NSIndexPath(row: 1, section: 0) as IndexPath
//                self.tableView?.reloadItemsAtIndexPaths([indexPath], animationStyle: .fade)
//            }
//        }
    }
    
    func onMediaItemPicked(mediaItemUrl: URL) {
        self.sendImagePublish.onNext(mediaItemUrl)
    }
    
    func onNewData(items: [MessageItem]) {
        // self.configurator?.setItems(items)
    }

    func onNewSingleData(item: MessageItem) {
        // self.configurator?.onNewSingleItem(item)
    }
    
    func onMediaItemPickFail() {
        print("Failed")
    }
    
    func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func clearText() {
        self.textMessageContent.text = ""
    }
    
    func goPickMedia() {
        self.resignFirstResponder()
        let vc = PickMediaVC.instance(delegate: self)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
