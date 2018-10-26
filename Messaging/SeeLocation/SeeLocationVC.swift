import UIKit
import GoogleMaps

class SeeLocationVC: UIViewController {

    class func instance(lat: Double, long: Double) -> UIViewController {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
        return SeeLocationVC(coordinate: coord)
    }
    
    init(coordinate coord: CLLocationCoordinate2D) {
        self.coordinate = coord
        super.init(nibName: "SeeLocationVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private let coordinate: CLLocationCoordinate2D
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cam = GMSCameraPosition(target: self.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
        mapView.camera = cam
        mapView.clear()
        let marker = GMSMarker(position: self.coordinate)
        marker.map = self.mapView
    }

}
