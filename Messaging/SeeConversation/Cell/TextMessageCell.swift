import UIKit

class TextMessageCell : BaseMessageCell {
    override var item: MessageItem! {
        didSet {
            self.textContent.text = item.message.getContent()
        }
    }
    
    override func prepareUI() {
        // Do UI setup
        self.addSubview(tvWrapper)
        addConstraintsForTextContent()
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        layoutIfNeeded()
        
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
    }
    
    private let textContent: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isUserInteractionEnabled = false
        tv.textColor = UIColor.black
        tv.backgroundColor = UIColor.clear
        tv.clipsToBounds = false
        tv.isScrollEnabled = false
        tv.sizeToFit()
        tv.font = UIFont.systemFont(ofSize: 15.0)
        // tv.contentInset = UIEdgeInsetsMake(8, 12, 8, 12)
        
        tv.textContainerInset = .zero
        tv.text = "Testing text view lalalala. And this is a long long text. I want to make it longer and longer. "
        return tv
    }()
    
    private let tvWrapper: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(red: 137 / 255.0, green: 229 / 255.0, blue: 163 / 255.0, alpha: 1)
        v.layer.cornerRadius = 16.0
        return v
    }()
    
    private func addConstraintsForTextContent() {
        let smallPadding = MessageCellConstant.smallPadding
        let normalPadding = MessageCellConstant.normalPadding
        let mainPadding = MessageCellConstant.mainPadding
        
        let topC = NSLayoutConstraint(item: tvWrapper, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: smallPadding)
        let botC = NSLayoutConstraint(item: tvWrapper, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: smallPadding * -1)
        let leftC = NSLayoutConstraint(item: tvWrapper, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: normalPadding)
        let rightC = NSLayoutConstraint(item: tvWrapper, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self, attribute: .trailing, multiplier: 1, constant: mainPadding * -1)
        
        addConstraints([topC, botC, leftC, rightC])
        
        
        let topC2 = NSLayoutConstraint(item: textContent, attribute: .top, relatedBy: .equal, toItem: tvWrapper, attribute: .top, multiplier: 1, constant: 8)
        let botC2 = NSLayoutConstraint(item: textContent, attribute: .bottom, relatedBy: .equal, toItem: tvWrapper, attribute: .bottom, multiplier: 1, constant: 8 * -1)
        let leftC2 = NSLayoutConstraint(item: textContent, attribute: .leading, relatedBy: .equal, toItem: tvWrapper, attribute: .leading, multiplier: 1, constant: 12)
        let rightC2 = NSLayoutConstraint(item: textContent, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: tvWrapper, attribute: .trailing, multiplier: 1, constant: 12 * -1)
        
        tvWrapper.addSubview(textContent)
        tvWrapper.addConstraints([topC2, botC2, leftC2, rightC2])
    }
}
