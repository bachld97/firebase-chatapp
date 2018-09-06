import UIKit
import RxSwift
import RxCocoa

class SeeChatHistoryVC: BaseVC, ViewFor {
    var viewModel: SeeChatHistoryViewModel!
    private var disposeBag = DisposeBag()
    
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
    }
}

extension SeeChatHistoryVC: SeeChatHistoryDisplayLogic {
    func goConversation() {
    }
    
    func showEmpty() {
    }
}
