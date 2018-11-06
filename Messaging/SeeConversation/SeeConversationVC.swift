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
    @IBOutlet weak var pickLocationButton: UIButton!
    @IBOutlet weak var pickDocumentButton: UIButton!
    
    private let sendContactPublish = PublishSubject<Contact>()
    private let sendImagePublish = PublishSubject<URL>()
    private let sendLocationPublish = PublishSubject<(Double, Double)>()
    private let sendFilePublish = PublishSubject<URL>()
    // private let sendEmojiPublish = PublishSubject<String>()
    
    private let onCreatePublish = PublishSubject<Void>()
    
    @IBOutlet weak var emojiPanel: UICollectionView!
    private let emojiDataSource = EmojiCollectionDataSource()
    
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
        
        self.emojiPanel.register(
            EmojiCollectionViewCell.self,
            forCellWithReuseIdentifier: "EmojiCollectionViewCell")
        
        self.layoutEmojis()
        self.emojiPanel.dataSource = self.emojiDataSource
        self.emojiPanel.delegate = self.emojiDataSource
        self.emojiPanel.autoresizingMask = UIViewAutoresizing(
            rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue)
                | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
//        self.layoutEmojis()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.emojiPanel?.collectionViewLayout.invalidateLayout()
    }
    
    func layoutEmojis() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        
        layout.minimumInteritemSpacing = 2.0
        layout.minimumLineSpacing = 2.0
        
        layout.itemSize = CGSize(width: 40, height: 40)
        
        emojiPanel.collectionViewLayout = layout
    }
    
    override func bindViewModel() {
        let buttonText = Variable("Send")
        buttonText.asObservable()
            .bind(to: sendMessageButton.rx.title())
            .disposed(by: self.disposeBag)
        
        let input = SeeConversationViewModel.Input(
            trigger: onCreatePublish.asDriverOnErrorJustComplete(),
            sendMessTrigger: self.sendMessageButton.rx.tap.asDriver(),
            sendMessDisplay: buttonText,
            conversationLabel: self.navigationItem.rx.title,
            textMessage: self.textMessageContent.rx.text.orEmpty,
            pickImageTrigger: self.pickImageButton.rx.tap.asDriver(),
            pickContactTrigger: self.pickContactButton.rx.tap.asDriver(),
            pickLocationTrigger: self.pickLocationButton.rx.tap.asDriver(),
            pickDocumentTrigger: self.pickDocumentButton.rx.tap.asDriver(),
            sendImagePublish: self.sendImagePublish.asDriverOnErrorJustComplete(),
            sendContactPublish: self.sendContactPublish.asDriverOnErrorJustComplete(),
            sendLocationPublish: self.sendLocationPublish.asDriverOnErrorJustComplete(),
            sendEmojiPublish: self.emojiDataSource.emojiPublish.asDriverOnErrorJustComplete(),
            sendFilePublish: self.sendFilePublish.asDriverOnErrorJustComplete())
        
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
        
        self.tableView?.register(LocationMeTimeMessageCell.self)
        self.tableView?.register(LocationTimeMessageCell.self)
        self.tableView?.register(LocationMeMessageCell.self)
        self.tableView?.register(LocationMessageCell.self)
        
        self.tableView?.register(FileMeTimeMessageCell.self)
        self.tableView?.register(FileMeMessageCell.self)
        
        self.tableView?.register(AudioMessageCell.self)
        self.tableView?.register(AudioTimeMessageCell.self)
    }
    
    private var interaction: UIDocumentInteractionController!
}

extension SeeConversationVC : SeeConversationDisplayLogic {
    func goShowImage(_ imageUrl: String) {
        self.resignFirstResponder()
        let vc = ViewImageVC.instance(imageToShow: imageUrl)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func notifyItems(with changes: [Change<MessageItem>]?) {
        guard changes != nil else {
            self.tableView?.reloadData()
            return
        }

        self.tableView?.reload(changes: changes!, completion: { (_) in })
    }
    
    func notifyItem(with addRespond: (Bool, Int)) {
        self.tableView?.reloadData()
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
    
    func goPickLocation() {
        self.resignFirstResponder()
        let vc = PickLocationVC.instance(delegate: self)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func goPickDocument() {
        self.resignFirstResponder()
        let vc = PickFileVC.instance(delegate: self)
        self.present(vc, animated: true, completion: nil)
    }
    
    func notifyTextCopied(with text: String) {
        super.doToast(with: "Message copied to clipboard",
                      duration: 1.2)
        UIPasteboard.general.string = text
    }
    
    func notifyFileDownloaded(_ name: String) {
        super.doToast(with: "File downloaded: \(name)",
                      duration: 1.2)
    }
    
    func goShowContact(_ contactId: String) {
        self.resignFirstResponder()
        let vc = SeeContactProfileVC.instance(userId: contactId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func goShowLocation(lat: Double, long: Double) {
        self.resignFirstResponder()
        let vc = SeeLocationVC.instance(lat: lat, long: long)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func viewFile(withUrl url: URL, withName name: String) {
        interaction = UIDocumentInteractionController(url: url)
        interaction.name = name
        interaction.delegate = self
        interaction.presentPreview(animated: true)
    }
}

extension SeeConversationVC : UIDocumentInteractionControllerDelegate {
    public func documentInteractionControllerViewControllerForPreview
        (_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    public func documentInteractionControllerDidEndPreview
        (_ controller: UIDocumentInteractionController) {
    }
}


extension SeeConversationVC : PickMediaDelegate, PickContactDelegate, PickLocationDelegate, PickFileDelegate {
    func onLocationPicked(latitude: Double, longitude: Double) {
        self.sendLocationPublish.onNext((latitude, longitude))
    }
    
    func onMediaItemPicked(mediaItemUrl: URL) {
        self.sendImagePublish.onNext(mediaItemUrl)
    }
    
    func onMediaItemPickFail() {
        print("Failed: PickMedia")
    }
    
    func onContactChoosen(contact: Contact) {
        self.sendContactPublish.onNext(contact)
    }
    
    func onFilePickFail() {
        print("Failed: PickFile")
    }
    
    func onFilePick(url: URL) {
        self.sendFilePublish.onNext(url)
    }
}
