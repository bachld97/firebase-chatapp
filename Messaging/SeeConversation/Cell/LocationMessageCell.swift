import UIKit
import RxSwift
import GoogleMaps

class LocationMessageCell : BaseMessageCell {
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
        }
    }
    
    
    private let mapView: GMSMapView = {
        let v = GMSMapView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = false
        v.heightAnchor.constraint(equalToConstant: 156.0).isActive = true
        v.widthAnchor.constraint(equalToConstant: 156.0).isActive = true
        v.backgroundColor = UIColor(red: 137 / 255.0, green: 229 / 255.0, blue: 163 / 255.0, alpha: 1)
        v.layer.cornerRadius = 16.0
        v.clipsToBounds = true
        return v
    }()
    
    override func prepareUI() {
        self.addSubview(mapView)
        addConstraintsForMapView()
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        layoutIfNeeded()
        
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
    }
    
    private func addConstraintsForMapView() {
        let mainPadding = MessageCellConstant.mainPadding
        let normalPadding = MessageCellConstant.normalPadding
        let smallPadding = MessageCellConstant.smallPadding
        
        let topC = NSLayoutConstraint(item: mapView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: smallPadding)
        let botC = NSLayoutConstraint(item: mapView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: smallPadding * -1)
        let leftC = NSLayoutConstraint(item: mapView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: normalPadding)
        let rightC = NSLayoutConstraint(item: mapView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self, attribute: .trailing, multiplier: 1, constant: mainPadding * -1)
        
        botC.priority = UILayoutPriority(rawValue: 999)
        addConstraints([topC, botC, leftC, rightC])
    }
}
