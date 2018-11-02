import UIKit
import GoogleMaps
import GooglePlaces
import MapKit
import RxSwift
import RxCocoa

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
    private var resultsViewController: GMSAutocompleteResultsViewController?
    private var searchController: UISearchController?
    private var coordinateToShare: CLLocationCoordinate2D!
    private let disposeBag = DisposeBag()
    
    let locationManager = CLLocationManager()
    private var labelCanChange = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
        self.mapView.delegate = self
        
        self.resultsViewController = GMSAutocompleteResultsViewController()
        self.resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController

        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        definesPresentationContext = true
        searchController?.hidesNavigationBarDuringPresentation = false
        
     
        pickButton.rx.tap
            .asDriver()
            .drive(onNext: { [unowned self] (_) in
                guard let coord = self.coordinateToShare else {
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                
                self.delegate?.onLocationPicked(latitude: coord.latitude, longitude: coord.longitude)
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.disposeBag)
    }
}

extension PickLocationVC: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        self.focusCoordinate(place.coordinate, with: place.name)
//        print("Place name: \(place.name)")
//        print("Place address: \(place.formattedAddress)")
//        print("Place attributions: \(place.attributions)")
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        print("Error: ", error.localizedDescription)
    }
}


extension PickLocationVC : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
//        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        mapView.animate(to: GMSCameraPosition(target: location.coordinate,
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
        // reverseGeocodeCoordinate(position.target)
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        self.labelCanChange = false
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        self.labelCanChange = true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mapView.animate(to: GMSCameraPosition(target: coordinate,
            zoom: 15, bearing: 0, viewingAngle: 0))
        
        self.focusCoordinate(coordinate)
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        guard labelCanChange else {
            return
        }
        
        self.focusCoordinate(coordinate)
    }
    
    private func focusCoordinate(_ coordinate: CLLocationCoordinate2D,
                                 with placeAddress: String?) {
        // move to coordinate
        mapView.animate(to: GMSCameraPosition(target: coordinate,
            zoom: 15, bearing: 0, viewingAngle: 0))
        
        guard let address = placeAddress else {
            self.focusCoordinate(coordinate)
            return
        }
        
        // Mark the latest location
        self.coordinateToShare = coordinate
        
        mapView.clear()
        let marker = GMSMarker(position: coordinate)
        marker.map = self.mapView
        
        self.addressLabel.text = address
        let labelHeight = self.displayGroup.frame.height
        self.mapView.padding = UIEdgeInsets(
            top: self.view.safeAreaInsets.top,
            left: 0, bottom: labelHeight, right: 0)
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
            self.displayGroup.isHidden = false
        }
    }
    
    private func focusCoordinate(_ coordinate: CLLocationCoordinate2D) {
        self.coordinateToShare = coordinate
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
    func onLocationPicked(latitude: Double, longitude: Double)
}
