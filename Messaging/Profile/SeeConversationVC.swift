import UIKit
import RxCocoa
import RxSwift 
import RxDataSources

class SeeConversationVC: BaseVC, ViewFor {
    var viewModel: SeeConversationViewModel!
    private let disposeBag = DisposeBag()
    typealias ViewModelType = SeeConversationViewModel
    
    @IBOutlet weak var textMessageContent: UITextField!
    
    @IBOutlet weak var sendImageButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendMessageButton: UIButton!
    
    private let sendImagePublish = PublishSubject<URL>()
    
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
        // self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.largeTitleDisplayMode = .never
        // self.navigationItem.title = "Helo"
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
        
//        self.tableView.register(UINib(nibName: "<++>", bundle: nil), forCellReusableIdentifier: "<++>")
        self.tableView.register(TextMessageCell.self, forCellReuseIdentifier: "TextMessageCell")
        self.tableView.register(ImageMessageCell.self, forCellReuseIdentifier: "ImageMessageCell")
        self.tableView.register(TextMeMessageCell.self, forCellReuseIdentifier: "TextMeMessageCell")
        self.tableView.register(ImageMeMessageCell.self, forCellReuseIdentifier: "ImageMeMessageCell")
        
        self.items = RxTableViewSectionedReloadDataSource
            <SectionModel<String, SeeConversationViewModel.Item>>(
                configureCell: { (_, tv, ip, item) -> UITableViewCell in
                    switch item {
                    case .image(let message):
                        let cell = tv.dequeueReusableCell(withIdentifier: "ImageMessageCell")
                            as! ImageMessageCell
                        cell.bind(message: message)
                        return cell
                        
                    case .imageMe(let message):
                        let cell = tv.dequeueReusableCell(withIdentifier: "ImageMeMessageCell")
                            as! ImageMeMessageCell
                        cell.bind(message: message)
                        return cell
                        
                    case .text(let message):
                        let cell = tv.dequeueReusableCell(withIdentifier: "TextMessageCell")
                            as! TextMessageCell
                        cell.bind(message: message)
                        return cell
                        
                    case .textMe(let message):
                        let cell = tv.dequeueReusableCell(withIdentifier: "TextMeMessageCell")
                            as! TextMeMessageCell
                        cell.bind(message: message)
                        return cell
                    }
            })
        
//        self.tableView.rx.itemSelected.asDriver()
//            .drive(onNext: { [unowned self] (ip) in
//
//            })
    }
    
    override func bindViewModel() {
        let viewWillAppear = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = SeeConversationViewModel.Input(
            trigger: viewWillAppear,
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
        
        output.items
            .map { [SectionModel(model: "Items", items: $0)]}
            .drive (self.tableView.rx.items(dataSource: self.items))
            .disposed(by: self.disposeBag)
    }
}

extension SeeConversationVC : SeeConversationDisplayLogic, PickMediaDelegate {
    func onMediaItemPicked(mediaItemUrl: URL) {
        self.sendImagePublish.onNext(mediaItemUrl)
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
        let vc = PickMediaVC.instance(delegate: self)
//        self.present(vc, animated: true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
