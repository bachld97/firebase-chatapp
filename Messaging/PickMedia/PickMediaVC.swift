import UIKit
import Photos

class PickMediaVC: BaseVC, UICollectionViewDelegate, UICollectionViewDataSource,
        UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    class func instance(delegate: PickMediaDelegate) -> UIViewController {
        return PickMediaVC(delegate: delegate)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(delegate: PickMediaDelegate) {
        super.init(nibName: "PickMediaVC", bundle: nil)
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Photos"
        
        askPermission()
    }
    
    
    private func setupUI() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.register(CameraCell.self, forCellWithReuseIdentifier: "CameraCell")
        collectionView.backgroundColor = UIColor.white
        self.view.addSubview(collectionView)
        
        collectionView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
    }
    
    weak var delegate: PickMediaDelegate?
    var collectionView: UICollectionView!
    var imageArray = [UIImage]()

    private func askPermission() {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined || photos == .denied {
            PHPhotoLibrary.requestAuthorization { [unowned self] (status) in
                if status == .authorized {
                    self.loadImages()
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else if photos == .authorized {
            self.loadImages()
        }
    }
    
    private func loadImages() {
        setupUI()
        
        imageArray = []
        
        DispatchQueue.global(qos: .background).async {
            let imgManager = PHImageManager.default()
            
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            requestOptions.deliveryMode = .highQualityFormat
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            if fetchResult.count > 0 {
                for i in 0..<fetchResult.count {
                    imgManager.requestImage(
                        for: fetchResult.object(at: i) as PHAsset,
                        targetSize: CGSize(width: 480, height: 480),
                        contentMode: .aspectFill,
                        options: requestOptions,
                        resultHandler: { [unowned self] (image, error) in
                            self.imageArray.append(image!)
                    })
                }
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        if index == 0 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "CameraCell", for: indexPath)
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
            cell.bind(imageToBind: imageArray[index - 1])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        if index == 0 {
            // Camera Cell
        } else {
            self.pickImageDone(image: imageArray[index - 1])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: width / 4 - 1, height: width / 4 - 1)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.collectionView?.collectionViewLayout.invalidateLayout()
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}
extension PickMediaVC {
    func pickImageDone(url: URL) {
        self.delegate?.onMediaItemPicked(mediaItemUrl: url)
    }
    
    func pickImageDone(image: UIImage) {
        // Save image to app's storage
        let mul = Compressor.estimatetMultiplier(forSize: image.size)
        print("compress: \(mul)")
        guard let data = UIImageJPEGRepresentation(image, mul) else {
            self.delegate?.onMediaItemPickFail()
            return
        }
        
        let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let filename = UUIDGenerator.newUUID() + ".jpeg"
        
        let url = URL(fileURLWithPath: path).appendingPathComponent(filename)
        do {
            try data.write(to: url)
            self.delegate?.onMediaItemPicked(mediaItemUrl: url)
        }
        catch {
            self.delegate?.onMediaItemPickFail()
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}
