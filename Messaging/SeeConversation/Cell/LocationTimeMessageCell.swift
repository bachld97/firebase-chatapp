import UIKit
import RxSwift
import GoogleMaps

class LocationTimeMessageCell : BaseMessageCell {
    private var disposeBag = DisposeBag()
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override var item: MessageItem! {
        didSet {
            let coord = item.message.getContent().split(separator: "_")
            let lat = Double(coord.first!)!
            let long = Double(coord.last!)!
            let loc = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let cam = GMSCameraPosition(target: loc, zoom: 15, bearing: 0, viewingAngle: 0)
            mapView.camera = cam
            mapView.clear()
            let marker = GMSMarker(position: loc)
            marker.map = self.mapView
            
            mapView.rx.tapGesture()
                .when(.ended)
                .asDriverOnErrorJustComplete()
                .drive(onNext: { [unowned self] _ in
                    self.clickPublish?.onNext(self.item)
                })
                .disposed(by: self.disposeBag)
            
            timeContent.text  = item.displayTime
        }
    }
    
    private let imageLoader = _ImageLoader()
    
    private let mapView: GMSMapView = {
        let v = GMSMapView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        v.isUserInteractionEnabled = false
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 156.0).isActive = true
        v.widthAnchor.constraint(equalToConstant: 156.0).isActive = true
        v.backgroundColor = UIColor(red: 137 / 255.0, green: 229 / 255.0, blue: 163 / 255.0, alpha: 1)
        v.layer.cornerRadius = 16.0
        v.clipsToBounds = true
        return v
    }()
    
    private let timeContent: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isUserInteractionEnabled = false
        tv.textColor = UIColor.black
        tv.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        tv.clipsToBounds = false
        tv.isScrollEnabled = false
        tv.sizeToFit()
        tv.font = UIFont.systemFont(ofSize: 10.0)
        tv.textContainerInset = .zero
        return tv
    }()
    
    override func prepareUI() {
        self.addSubview(mapView)
        self.addSubview(timeContent)
        
        addConstraintsForImage()
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        layoutIfNeeded()
        
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
    }
    
    private func addConstraintsForImage() {
        let mainPadding = MessageCellConstant.mainPadding
        let normalPadding = MessageCellConstant.normalPadding
        let smallPadding = MessageCellConstant.smallPadding
        
        let topC = NSLayoutConstraint(item: mapView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: smallPadding)
        // let botC = NSLayoutConstraint(item: contentImage, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: smallPadding * -1)
        let leftC = NSLayoutConstraint(item: mapView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: normalPadding)
        let rightC = NSLayoutConstraint(item: mapView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self, attribute: .trailing, multiplier: 1, constant: mainPadding * -1)
        
        let topC2 = NSLayoutConstraint(item: timeContent, attribute: .top, relatedBy: .equal, toItem: mapView, attribute: .bottom, multiplier: 1, constant: smallPadding)
        let leftC2 = NSLayoutConstraint(item: timeContent, attribute: .leading, relatedBy: .equal, toItem: mapView, attribute: .leading, multiplier: 1, constant: 4)
        let rightC2 = NSLayoutConstraint(item: timeContent, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self, attribute: .trailing, multiplier: 1, constant: mainPadding * -1)
        let botC2 = NSLayoutConstraint(item: timeContent, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: smallPadding * -1)
        
        botC2.priority = UILayoutPriority(rawValue: 999)
        addConstraints([topC, leftC, rightC, topC2, leftC2, rightC2, botC2])
    }
}
