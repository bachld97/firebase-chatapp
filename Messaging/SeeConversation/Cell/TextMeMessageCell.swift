import RxSwift
import RxCocoa
import UIKit

class TextMeMessageCell: BaseMessageCell {
    override var item: MessageItem! {
        didSet {
            // Compute attributed text
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
            
            resendButton.rx.tap
                .asDriver()
                .drive(onNext: { [unowned self] in
                    self.messagePublish?.onNext(self.item)
                })
                .disposed(by: self.disposeBag)
            
            if item.message.isSending {
                self.resendButton.isHidden = true
                self.tvWrapper.backgroundColor = UIColor(red: 221.0 / 255.0, green: 190.0 / 255.0, blue: 200 / 255.0, alpha: 1)
            } else {
                if item.message.isFail {
                    self.resendButton.isHidden = false
                    self.tvWrapper.backgroundColor = UIColor(red: 80.0 / 255.0, green: 80.0 / 255.0, blue: 200 / 255.0, alpha: 1)
                } else {
                    self.resendButton.isHidden = true
                    self.tvWrapper.backgroundColor = UIColor(red: 221.0 / 255.0, green: 234.0 / 255.0, blue: 1, alpha: 1)
                }
            }
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
        self.addSubview(resendButton)
        addConstraintsForTextContent()
        addConstraintsForResendButton()
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        layoutIfNeeded()
    
        
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
    }
    
    private let resendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true

        button.widthAnchor.constraint(equalToConstant: 16.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
        
        button.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.3)
        button.layer.cornerRadius = 8.0
        button.clipsToBounds = true
        button.setImage(#imageLiteral(resourceName: "ic_reload"), for: .normal)
        return button
    }()
    
    private let textContent: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isUserInteractionEnabled = false
        tv.textColor = UIColor.black
        tv.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        tv.clipsToBounds = false
        tv.isScrollEnabled = false
        tv.sizeToFit()
        tv.font = UIFont.systemFont(ofSize: 15.0)
        // tv.contentInset = UIEdgeInsetsMake(8, 12, 8, 12)
        
        tv.text = "Testing text view lalalala. And this is a long long text. I want to make it longer and longer. "
        return tv
    }()
    
    private let tvWrapper: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(red: 221.0 / 255.0, green: 234.0 / 255.0, blue: 1, alpha: 1)
        v.layer.cornerRadius = 16.0
        return v
    }()
    
    private func addConstraintsForResendButton() {
        let smallPadding = MessageCellConstant.smallPadding

        let topC = NSLayoutConstraint(item: resendButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
//        let botC = NSLayoutConstraint(item: resendButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        let rightC = NSLayoutConstraint(item: resendButton, attribute: .trailing, relatedBy: .equal, toItem: tvWrapper, attribute: .leading, multiplier: 1, constant: smallPadding)
        
        addConstraints([topC, rightC])
    }
    
    private func addConstraintsForTextContent() {
        let normalPadding = MessageCellConstant.normalPadding
        let smallPadding = MessageCellConstant.smallPadding
        let mainPadding = MessageCellConstant.mainPadding

        let topC = NSLayoutConstraint(item: tvWrapper, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: smallPadding)
        let botC = NSLayoutConstraint(item: tvWrapper, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: smallPadding * -1)
        let leftC = NSLayoutConstraint(item: tvWrapper, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leading, multiplier: 1, constant: mainPadding)
        let rightC = NSLayoutConstraint(item: tvWrapper, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: normalPadding * -1)
        
        addConstraints([topC, botC, leftC, rightC])
        
        let topC2 = NSLayoutConstraint(item: textContent, attribute: .top, relatedBy: .equal, toItem: tvWrapper, attribute: .top, multiplier: 1, constant: 8)
        let botC2 = NSLayoutConstraint(item: textContent, attribute: .bottom, relatedBy: .equal, toItem: tvWrapper, attribute: .bottom, multiplier: 1, constant: 8 * -1)
        let leftC2 = NSLayoutConstraint(item: textContent, attribute: .leading, relatedBy: .equal, toItem: tvWrapper, attribute: .leading, multiplier: 1, constant: 12)
        let rightC2 = NSLayoutConstraint(item: textContent, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: tvWrapper, attribute: .trailing, multiplier: 1, constant: 12 * -1)
        
        tvWrapper.addSubview(textContent)
        tvWrapper.addConstraints([topC2, botC2, leftC2, rightC2])
    }
}

