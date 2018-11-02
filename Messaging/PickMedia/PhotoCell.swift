import UIKit

class PhotoCell : UICollectionViewCell {
    
    var imgView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        self.addSubview(imgView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    func bind(imageToBind img: UIImage) {
        imgView.image = img
    }
}

