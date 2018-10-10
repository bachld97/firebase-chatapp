import UIKit

class ViewImageVC: BaseVC, UIScrollViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    class func instance(imageToShow urlString: String) -> UIViewController {
        return ViewImageVC(imageUrl: urlString)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private let imageUrl: String
    private let imageLoader = _ImageLoader()
    
    init(imageUrl: String) {
        self.imageUrl = imageUrl
        super.init(nibName: "ViewImageVC", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        setMaxScroll()
        centerImage()
    }
    
    private func setMaxScroll() {
        // TODO: The scrollView has wierd scrolling behavior, try to fix
    }
    
    override func prepareUI() {
        imageLoader.loadImage(url: imageUrl, into: self.imageView)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
    
    private func centerImage() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
        } else {
            contentsFrame.origin.x = 0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
        } else {
            contentsFrame.origin.y = 0
        }
        
        imageView.frame = contentsFrame
    }
}
