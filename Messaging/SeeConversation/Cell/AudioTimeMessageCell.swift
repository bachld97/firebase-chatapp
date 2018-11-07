import UIKit
import RxSwift

class AudioTimeMessageCell : AudioMessageCell {
    
    override var item: MessageItem! {
        didSet {
            // super.didSet(item) automatically fired,
            // don't need to do it manually.
            timeContent.text = item.displayTime
        }
    }
    
    private var timeContent: UITextView = {
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
        tv.text = "Test"
        return tv
    }()
    
    override func prepareUI() {
        super.prepareUI()
        super.addSubview(timeContent)
        let mainPadding = MessageCellConstant.mainPadding
        let smallPadding = MessageCellConstant.smallPadding
        
        let timeTop = NSLayoutConstraint(item: timeContent, attribute: .top, relatedBy: .equal,
                                         toItem: container, attribute: .bottom, multiplier: 1, constant: smallPadding)
        let timeLeft = NSLayoutConstraint(item: timeContent, attribute: .leading, relatedBy: .equal,
                                          toItem: container, attribute: .leading, multiplier: 1, constant: 4)
        let timeRight = NSLayoutConstraint(item: timeContent, attribute: .trailing, relatedBy: .lessThanOrEqual,
                                           toItem: self, attribute: .trailing, multiplier: 1, constant: mainPadding * -1)
        let timeBot = NSLayoutConstraint(item: timeContent, attribute: .bottom, relatedBy: .equal,
                                         toItem: self, attribute: .bottom, multiplier: 1, constant: -20)//-smallPadding)
        
        self.addConstraints([timeTop, timeLeft, timeRight, timeBot])

        // remove constraint of container -> bot(self)
    }
}

