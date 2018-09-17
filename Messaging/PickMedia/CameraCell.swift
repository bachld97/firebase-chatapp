import UIKit

class CameraCell : UICollectionViewCell {
    
    var imgView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.image = #imageLiteral(resourceName: "ic_search_user")
        self.addSubview(imgView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
}

