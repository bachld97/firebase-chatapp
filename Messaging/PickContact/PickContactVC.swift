import UIKit
import RxDataSources
import RxSwift

class PickContactVC: BaseVC, ViewFor {
    class func instance(delegate: PickContactDelegate) -> UIViewController {
        return PickContactVC(delegate: delegate)
    }

    private weak var delegate: PickContactDelegate?
    typealias ViewModelType = PickContactViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    var viewModel: PickContactViewModel!

    weak var tableView: UITableView?
    
    private var items: RxTableViewSectionedReloadDataSource<SectionModel<String, ContactItem>>!
    
    init(delegate: PickContactDelegate) {
        super.init(nibName: "PickContactVC", bundle: nil)
        self.delegate = delegate
        self.viewModel = PickContactViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindViewModel() {
        let viewWillAppear =
            self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
                .mapToVoid()
                .asDriverOnErrorJustComplete()
        
        let input = PickContactViewModel.Input(
            trigger: viewWillAppear
        )
        
        let output = self.viewModel.transform(input: input)
        
        output.error
            .drive(onNext: { [unowned self] error in
                self.handleError(e: error)
            })
            .disposed(by: self.disposeBag)
        
        output.items
            .map { [SectionModel(model: "Items", items: $0)]}
            .drive (self.tableView!.rx.items(dataSource: self.items))
            .disposed(by: self.disposeBag)
    }
    
    override func prepareUI() {
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        let tableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        self.view.addSubview(tableView)
        self.tableView = tableView
        self.tableView?.tableFooterView = UIView()
        self.tableView?.rowHeight = 72
        
        self.tableView?.register(
            UINib(nibName: "ContactCell", bundle: nil),
            forCellReuseIdentifier: "ContactCell")
        
        self.items = RxTableViewSectionedReloadDataSource<SectionModel<String, ContactItem>>(
            configureCell: { (_, tv, ip, item) -> UITableViewCell in
                let cell = tv.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
                cell.bind(item: item)
                return cell
        })
        
        
        self.tableView?.rx
            .itemSelected.asDriver()
            .drive(onNext: { [unowned self] (ip) in
                self.tableView?.deselectRow(at: ip, animated: false)
                let contactItem = self.items.sectionModels[0].items[ip.row]
                self.delegate?.onContactChoosen(contact: contactItem.contact)
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.disposeBag)
    }
}
