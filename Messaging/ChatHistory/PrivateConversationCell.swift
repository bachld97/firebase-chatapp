import UIKit

class PrivateConversationCell : BaseConversationCell {
    override var item: ConversationItem! {
        didSet {
            self.titleText.text = item.displayTitle
            self.contentText.text = item.displayContent
            self.timeText.text = item.displayTime
            imageLoader.loadImage(url: item.displayAva, into: self.avaImage)
        }
    }
    
    private let imageLoader = _ImageLoader()
    
    private let avaImage: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.darkGray
        v.layer.cornerRadius = 20.0
        v.clipsToBounds = true
        return v
    }()
    
    private let titleText: UITextField = {
        let v = UITextField()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = false
        v.textColor = UIColor.darkText
        v.backgroundColor = UIColor.clear
        v.clipsToBounds = true
        v.font = UIFont.systemFont(ofSize: 15.0)
        v.text = "Jake Shimabukuro"
        return v
    }()
    
    private let timeText: UITextField = {
        let v = UITextField()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = false
        v.textColor = UIColor.darkGray
        v.backgroundColor = UIColor.clear
        v.clipsToBounds = true
        v.font = UIFont.systemFont(ofSize: 11.0)
        v.textAlignment = NSTextAlignment.right
        v.text = "12:00"
        return v
    }()
    
    private let contentText: UITextField = {
        let v = UITextField()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = false
        v.textColor = UIColor.darkGray
        v.backgroundColor = UIColor.clear
        v.clipsToBounds = true
        v.font = UIFont.systemFont(ofSize: 13.0)
        v.text = "Let's jam together. This weekend, my place!"
        return v
    }()
    
    override func prepareUI() {
        // Add subviews, including: 1 imgview, 3 text field
        self.addSubview(self.avaImage)
        self.addSubview(self.titleText)
        self.addSubview(self.contentText)
        self.addSubview(self.timeText)
    }
    
    override func layoutSubviews() {
        let width = self.frame.width
        
        self.avaImage.frame = CGRect(x: 8, y: 16, width: 40, height: 40)
        self.timeText.frame = CGRect(x: width - 48, y: 16, width: 40, height: 16)
        self.titleText.frame = CGRect(x: 64, y: 16, width: width - (48 + 8 + 56), height: 20)
        self.contentText.frame = CGRect(x: 64, y: 36, width: width - (8 + 56 + 8), height: 20)
    }
}
