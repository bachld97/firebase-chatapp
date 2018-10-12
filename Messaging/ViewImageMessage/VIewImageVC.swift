import RxCocoa
import RxSwift
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
    }
    
    private func setMaxScroll() {
        if scrollView.zoomScale == 1.0 {
            scrollView.isScrollEnabled = false
        } else {
        scrollView.isScrollEnabled = true
        }
    }
    
    override func prepareUI() {
        imageLoader.loadImage(url: imageUrl, into: self.imageView)
        setMaxScroll()
        centerImage()
        scrollView.delegate = self
        
        self.scrollView.rx
            .tapGesture(numberOfTouchesRequired: 1, numberOfTapsRequired: 2, configuration: nil)
            .when(.ended)
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [unowned self] gesture in
                self.handleTapZoom(gesture)
            })
            .disposed(by: self.disposeBag)
    }

    private var disposeBag = DisposeBag()
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setMaxScroll()
        centerImage()
    }
  
    private func handleTapZoom(_ gesture: UIGestureRecognizer) {
//        if (self.zoomScale > self.minimumZoomScale)
//        {
//            [self setZoomScale:self.minimumZoomScale animated:YES];
//        }
//        else
//        {
//            CGPoint touch = [recognizer locationInView:recognizer.view];
//
//            CGSize scrollViewSize = self.bounds.size;
//
//            CGFloat w = scrollViewSize.width / self.maximumZoomScale;
//            CGFloat h = scrollViewSize.height / self.maximumZoomScale;
//            CGFloat x = touch.x-(w/2.0);
//            CGFloat y = touch.y-(h/2.0);
//
//            CGRect rectTozoom=CGRectMake(x, y, w, h);
//            [self zoomToRect:rectTozoom animated:YES];
//        }
        if scrollView.zoomScale > 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let touchPoint = gesture.location(in: scrollView)
            let size = scrollView.bounds.size
            
            let maxZoom = scrollView.maximumZoomScale
            let w = size.width / maxZoom
            let h = size.height / maxZoom
            let x = touchPoint.x - (w / 2.0)
            let y = touchPoint.y - (h / 2.0)
            
            let rec = CGRect(x: x, y: y, width: w, height: h)
            scrollView.zoom(to: rec, animated: true)
        }
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
