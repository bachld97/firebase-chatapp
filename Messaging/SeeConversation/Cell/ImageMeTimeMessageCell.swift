import UIKit
import RxSwift
import RxCocoa

class ImageMeTimeMessageCell : BaseMessageCell {
    override var item: MessageItem! {
        didSet {
            let url = item.message.getContent()
            let messageId = item.message.getMessageId()
            imageLoader.loadMessageImage(url: url, id: messageId, into: self.contentImage)
            timeContent.text = item.displayTime
            
            resendButton.rx.tap
                .asDriver()
                .drive(onNext: { [unowned self] in
                    self.messagePublish?.onNext(self.item)
                })
                .disposed(by: self.disposeBag)
            
            contentImage.rx.tapGesture()
                .when(.ended)
                .asDriverOnErrorJustComplete()
                .drive(onNext: { [unowned self] _ in
                    self.clickPublish?.onNext(self.item)
                })
                .disposed(by: self.disposeBag)
            
            if item.message.isSending {
                self.resendButton.isHidden = true
                contentImage.alpha = 0.5
            } else {
                if item.message.isFail {
                    self.resendButton.isHidden = false
                } else {
                    self.resendButton.isHidden = true
                    contentImage.alpha = 1.0
                }
            }
        }
    }
    
    private let imageLoader = _ImageLoader()
    
    private let contentImage: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 96.0).isActive = true
        v.widthAnchor.constraint(equalToConstant: 96.0).isActive = true
        
        v.backgroundColor = UIColor(red: 221.0 / 255.0, green: 234.0 / 255.0, blue: 1, alpha: 1)
        v.layer.cornerRadius = 16.0
        v.clipsToBounds = true
        return v
    }()
    
    private func addConstraintsForResendButton() {
        let smallPadding = MessageCellConstant.smallPadding
        
        let topC = NSLayoutConstraint(item: resendButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let rightC = NSLayoutConstraint(item: resendButton, attribute: .trailing, relatedBy: .equal, toItem: contentImage, attribute: .leading, multiplier: 1, constant: smallPadding)
        
        addConstraints([topC, rightC])
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
    
    private let timeContent: UITextView = {
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
        return tv
    }()
    
    private var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func prepareUI() {
        self.addSubview(contentImage)
        self.addSubview(timeContent)
        addConstraintsForImage()
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        layoutIfNeeded()
        
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
    }
    
    private func addConstraintsForImage() {
        let mainPadding = MessageCellConstant.mainPadding
        let smallPadding = MessageCellConstant.smallPadding
        let normalPadding = MessageCellConstant.normalPadding
        
        let topC = NSLayoutConstraint(item: contentImage, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: smallPadding)
//        let botC = NSLayoutConstraint(item: contentImage, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: smallPadding * -1)
        let leftC = NSLayoutConstraint(item: contentImage, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leading, multiplier: 1, constant: mainPadding)
        let rightC = NSLayoutConstraint(item: contentImage, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: normalPadding * -1)
        
        let topC2 = NSLayoutConstraint(item: timeContent, attribute: .top, relatedBy: .equal, toItem: contentImage, attribute: .bottom, multiplier: 1, constant: smallPadding)
        let leftC2 = NSLayoutConstraint(item: timeContent, attribute: .leading, relatedBy: .equal, toItem: contentImage, attribute: .leading, multiplier: 1, constant: 4)
        let rightC2 = NSLayoutConstraint(item: timeContent, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: normalPadding * -1)
        let botC2 = NSLayoutConstraint(item: timeContent, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: smallPadding * -1)

        
        botC2.priority = UILayoutPriority(rawValue: 999)
        addConstraints([topC, botC2, leftC, rightC, topC2, leftC2, rightC2])
    }
}

