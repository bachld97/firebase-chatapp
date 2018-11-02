import GoogleMaps
import UIKit
import RxSwift
import RxCocoa

class LocationMeTimeMessageCell : BaseMessageCell {
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
            
            timeContent.text = item.displayTime
            
            resendButton.rx.tap
                .asDriver()
                .drive(onNext: { [unowned self] in
                    self.messagePublish?.onNext(self.item)
                })
                .disposed(by: self.disposeBag)
            
            mapView.rx.tapGesture()
                .when(.ended)
                .asDriverOnErrorJustComplete()
                .drive(onNext: { [unowned self] _ in
                    self.clickPublish?.onNext(self.item)
                })
                .disposed(by: self.disposeBag)
            
            if item.message.isSending {
                self.resendButton.isHidden = true
                mapView.alpha = 0.5
            } else {
                if item.message.isFail {
                    self.resendButton.isHidden = false
                } else {
                    self.resendButton.isHidden = true
                    mapView.alpha = 1.0
                }
            }
        }
    }
        
    private let mapView: GMSMapView = {
        let v = GMSMapView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 96.0).isActive = true
        v.widthAnchor.constraint(equalToConstant: 96.0).isActive = true
        v.isUserInteractionEnabled = false
        v.backgroundColor = UIColor(red: 221.0 / 255.0, green: 234.0 / 255.0, blue: 1, alpha: 1)
        v.layer.cornerRadius = 16.0
        v.clipsToBounds = true
        return v
    }()
    
    private func addConstraintsForResendButton() {
        let smallPadding = MessageCellConstant.smallPadding
        
        let topC = NSLayoutConstraint(item: resendButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let rightC = NSLayoutConstraint(item: resendButton, attribute: .trailing, relatedBy: .equal, toItem: mapView, attribute: .leading, multiplier: 1, constant: smallPadding)
        
        addConstraints([topC, rightC])
    }
    
    private let resendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        
        button.widthAnchor.constraint(equalToConstant: 16.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
        
        button.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.3)
        button.layer.cornerRadius = 8.0
        button.clipsToBounds = true
        button.setImage(#imageLiteral(resourceName: "ic_reload"), for: .normal)
        return button
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
    
    private var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func prepareUI() {
        self.addSubview(mapView)
        self.addSubview(timeContent)
        addConstraintsForMapView()
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        layoutIfNeeded()
        
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
    }
    
    private func addConstraintsForMapView() {
        let mainPadding = MessageCellConstant.mainPadding
        let smallPadding = MessageCellConstant.smallPadding
        let normalPadding = MessageCellConstant.normalPadding
        
        let topC = NSLayoutConstraint(item: mapView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: smallPadding)
        //        let botC = NSLayoutConstraint(item: contentImage, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: smallPadding * -1)
        let leftC = NSLayoutConstraint(item: mapView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leading, multiplier: 1, constant: mainPadding)
        let rightC = NSLayoutConstraint(item: mapView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: normalPadding * -1)
        
        let topC2 = NSLayoutConstraint(item: timeContent, attribute: .top, relatedBy: .equal, toItem: mapView, attribute: .bottom, multiplier: 1, constant: smallPadding)
        let leftC2 = NSLayoutConstraint(item: timeContent, attribute: .leading, relatedBy: .equal, toItem: mapView, attribute: .leading, multiplier: 1, constant: 4)
        let rightC2 = NSLayoutConstraint(item: timeContent, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: normalPadding * -1)
        let botC2 = NSLayoutConstraint(item: timeContent, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: smallPadding * -1)
        
        
        botC2.priority = UILayoutPriority(rawValue: 999)
        addConstraints([topC, botC2, leftC, rightC, topC2, leftC2, rightC2])
    }
}

