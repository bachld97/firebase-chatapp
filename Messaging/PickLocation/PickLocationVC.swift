import UIKit
import GoogleMaps
import MapKit

class PickLocationVC: UIViewController {

    class func instance(delegate: PickLocationDelegate) -> UIViewController {
        return PickLocationVC(delegate: delegate)
    }
    
    init(delegate: PickLocationDelegate) {
        super.init(nibName: "PickLocationVC", bundle: nil)
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var pickButton: UIButton!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var displayGroup: UIView!
    private weak var delegate: PickLocationDelegate?
    let locationManager = CLLocationManager()
    private var labelCanChange = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
        self.mapView.delegate = self
    }
    
//    override func loadView() {
//        let mapView = GMSMapView(frame: CGRect.zero)
//        mapView.settings.myLocationButton = true
//        mapView.isMyLocationEnabled = true
//
//        view = mapView
//    }
    
}

extension PickLocationVC : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
//        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        mapView.animate(to: GMSCameraPosition(
            target: location.coordinate,
            zoom: 15, bearing: 0, viewingAngle: 0))
        
        locationManager.stopUpdatingLocation()
        self.focusCoordinate(location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        locationManager.startUpdatingLocation()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}

extension PickLocationVC : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        self.labelCanChange = false
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        self.labelCanChange = true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        mapView.camera = GMSCameraPosition(target: coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        mapView.animate(to: GMSCameraPosition(
            target: coordinate,
            zoom: 15, bearing: 0, viewingAngle: 0))
        
        self.focusCoordinate(coordinate)
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        guard labelCanChange else {
            return
        }
        
        self.focusCoordinate(coordinate)
    }
    
    
    private func focusCoordinate(_ coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        let marker = GMSMarker(position: coordinate)
        marker.map = self.mapView
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(),
                let lines = address.lines else {
                    return
            }
            
            let displayTitle = lines.joined(separator: "\n")
            self.addressLabel.text = displayTitle
            
//            let labelHeight = self.addressLabel.intrinsicContentSize.height
            let labelHeight = self.displayGroup.frame.height
            self.mapView.padding = UIEdgeInsets(
                top: self.view.safeAreaInsets.top,
                left: 0, bottom: labelHeight, right: 0)
            
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
                self.displayGroup.isHidden = false
            }
        }
    }
}

protocol PickLocationDelegate : class {
    
}
