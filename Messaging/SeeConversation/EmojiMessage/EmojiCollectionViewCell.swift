import UIKit

class EmojiCollectionViewCell : UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }
    
    func prepareUI() {
//        self.backgroundColor = UIColor.lightGray

        self.addSubview(emojiDisplay)
        
        //
        let topC = NSLayoutConstraint(item: emojiDisplay, attribute: .top, relatedBy: .equal,
                                      toItem: self, attribute: .top, multiplier: 1, constant: 4)
        
        let botC = NSLayoutConstraint(item: emojiDisplay, attribute: .bottom, relatedBy: .equal,
                                      toItem: self, attribute: .bottom, multiplier: 1, constant: -4)
        
        let leftC = NSLayoutConstraint(item: emojiDisplay, attribute: .leading, relatedBy: .equal,
                                       toItem: self, attribute: .leading, multiplier: 1, constant: 12)
        
        let rightC = NSLayoutConstraint(item: emojiDisplay, attribute: .trailing,
                                        relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -8)
        
        addConstraints([topC, botC, leftC, rightC])
        self.layoutIfNeeded()
    }
    
    var emojiDisplay: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "Hello world"
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(:coder) is not implmented")
    }
    
    func bind(emoji: String) {
        self.emojiDisplay.text = emoji
    }
}
