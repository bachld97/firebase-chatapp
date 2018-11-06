import UIKit
import RxSwift

class TextMessageCell : BaseMessageCell {
    override var item: MessageItem! {
        didSet {
            // TODO: May pre-compute attributedText and store in messageItem
            let htmlData = NSString(string: item.message.getContent())
                .data(using: String.Encoding.unicode.rawValue)
            let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
            let attrText = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
            self.textContent.attributedText = attrText
            
            self.tvWrapper.rx.tapGesture()
                .when(.ended)
                .asDriverOnErrorJustComplete()
                .drive(onNext: { [unowned self] _ in
                    self.clickPublish?.onNext(self.item)
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    private var disposeBag = DisposeBag()
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
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
        v.backgroundColor = Setting.getCellColor(for: .otherUser)
        v.layer.cornerRadius = 16.0
        return v
    }()
    
    private func addConstraintsForTextContent() {
        let smallPadding = MessageCellConstant.smallPadding
        let normalPadding = MessageCellConstant.normalPadding
        let mainPadding = MessageCellConstant.mainPadding
        
        let topC = NSLayoutConstraint(item: tvWrapper, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: smallPadding)
        let botC = NSLayoutConstraint(item: tvWrapper, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -smallPadding)
        let leftC = NSLayoutConstraint(item: tvWrapper, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: normalPadding)
        let rightC = NSLayoutConstraint(item: tvWrapper, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self, attribute: .trailing, multiplier: 1, constant: -mainPadding)
        
        addConstraints([topC, botC, leftC, rightC])
        
        
        let topC2 = NSLayoutConstraint(item: textContent, attribute: .top, relatedBy: .equal, toItem: tvWrapper, attribute: .top, multiplier: 1, constant: 8)
        let botC2 = NSLayoutConstraint(item: textContent, attribute: .bottom, relatedBy: .equal, toItem: tvWrapper, attribute: .bottom, multiplier: 1, constant: 8 * -1)
        let leftC2 = NSLayoutConstraint(item: textContent, attribute: .leading, relatedBy: .equal, toItem: tvWrapper, attribute: .leading, multiplier: 1, constant: 12)
        let rightC2 = NSLayoutConstraint(item: textContent, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: tvWrapper, attribute: .trailing, multiplier: 1, constant: 12 * -1)
        
        tvWrapper.addSubview(textContent)
        tvWrapper.addConstraints([topC2, botC2, leftC2, rightC2])
    }
}
