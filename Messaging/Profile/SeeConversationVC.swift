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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendMessageButton: UIButton!
    
    @IBOutlet weak var pickContactButton: UIButton!
    @IBOutlet weak var pickImageButton: UIButton!
    
    private let sendContactPublish = PublishSubject<Contact>()
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
            pickImageTrigger: self.pickImageButton.rx.tap.asDriver(),
            pickContactTrigger: self.pickContactButton.rx.tap.asDriver(),
            sendImagePublish: self.sendImagePublish.asDriverOnErrorJustComplete(),
            sendContactPublish: self.sendContactPublish.asDriverOnErrorJustComplete())
        
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
        
        self.tableView?.register(ContactMessageCell.self)
        self.tableView?.register(ContactTimeMessageCell.self)
        self.tableView?.register(ContactMeMessageCell.self)
        self.tableView?.register(ContactMeTimeMessageCell.self)
    }
}

extension SeeConversationVC : SeeConversationDisplayLogic {
    func goShowImage(_ imageUrl: String) {
        self.resignFirstResponder()
        let vc = ViewImageVC.instance(imageToShow: imageUrl)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func notifyItems(with changes: [Change<MessageItem>]?) {
        self.tableView?.reloadData()
        
//        guard changes != nil else {
//            self.tableView?.reloadData()
//            return
//        }
//        
//        self.tableView?.reload(changes: changes!, completion: { (_) in })
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
    
    func goPickContact() {
        self.resignFirstResponder()
        let vc = PickContactVC.instance(delegate: self)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func notifyTextCopied(with text: String) {
        super.doToast(with: "Message copied to clipboard",
                      duration: 1.2)
        UIPasteboard.general.string = text
    }
    
    func goShowContact(_ contactId: String) {
        print("It works!")
        self.resignFirstResponder()
        let vc = SeeContactProfileVC.instance(userId: contactId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SeeConversationVC : PickMediaDelegate, PickContactDelegate {
    func onMediaItemPicked(mediaItemUrl: URL) {
        self.sendImagePublish.onNext(mediaItemUrl)
    }
    
    func onMediaItemPickFail() {
        print("Failed")
    }
    
    func onContactChoosen(contact: Contact) {
        self.sendContactPublish.onNext(contact)
    }
}
