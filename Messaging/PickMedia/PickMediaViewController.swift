import Photos
import UIKit

class PickMediaViewController: BaseVC {

    weak var delegate: PickMediaDelegate?
    var collectionView: UICollectionView!
    
    
    class func instance(delegate: PickMediaDelegate) -> UIViewController {
        return PickMediaViewController(delegate: delegate)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(delegate: PickMediaDelegate) {
        super.init(nibName: "PickMediaViewController", bundle: nil)
        self.delegate = delegate
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Photos"
    }

    private func setupUI() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
//        collectionView.delegate = self
//        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.register(CameraCell.self, forCellWithReuseIdentifier: "CameraCell")
        collectionView.backgroundColor = UIColor.white
        self.view.addSubview(collectionView)
        
        collectionView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
    }
}
