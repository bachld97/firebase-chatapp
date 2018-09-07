import UIKit
import RxCocoa
import RxSwift 
import RxDataSources

class SeeConversationVC: BaseVC, ViewFor {
    var viewModel: SeeConversationViewModel!
    private let disposeBag = DisposeBag()
    typealias ViewModelType = SeeConversationViewModel
    
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var conversationLabel: UILabel!
    
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
    

    override func bindViewModel() {
        let viewWillAppear = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = SeeConversationViewModel.Input(
            trigger: viewWillAppear,
            goBackTrigger: goBackButton.rx.tap.asDriver(),
            conversationLabel: conversationLabel.rx.text)
        
        let output = self.viewModel.transform(input: input)
        
        output.error
            .drive(onNext: { [unowned self]  error in
                self.handleError(e: error)
            })
        .disposed(by: self.disposeBag)
    }
}

extension SeeConversationVC : SeeConversationDisplayLogic {
    func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
}
