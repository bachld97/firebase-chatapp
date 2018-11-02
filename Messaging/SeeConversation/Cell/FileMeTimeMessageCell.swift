import UIKit
import RxSwift

class FileMeTimeMessageCell: BaseMessageCell {
    override var item: MessageItem! {
        didSet {
            let c = item.message.getContent()
            let content: String
            if c.contains(" ") {
                content = String(c.split(separator: " ").last!)
            } else {
                content = c
            }
            
            self.textContent.text = "[File] \(content)"
            self.timeContent.text = item.displayTime
            
            self.container.rx.tapGesture()
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
                self.container.backgroundColor = UIColor(red: 221.0 / 255.0, green: 190.0 / 255.0, blue: 200 / 255.0, alpha: 1)
            } else {
                if item.message.isFail {
                    self.resendButton.isHidden = false
                    self.container.backgroundColor = UIColor(red: 80.0 / 255.0, green: 80.0 / 255.0, blue: 200 / 255.0, alpha: 1)
                } else {
                    self.resendButton.isHidden = true
                    self.container.backgroundColor = UIColor(red: 221.0 / 255.0, green: 234.0 / 255.0, blue: 1, alpha: 1)
                }
            }
            
            if let documentItem = item as? DocumentMessageItem {
                if documentItem.isDocumentDownloaded {
                    self.downloadStatusImage.image = UIImage(named: "ic_open")
                    print("Document downloaded")
                } else {
                    self.downloadStatusImage.image = UIImage(named: "ic_download_new")
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    private var disposeBag = DisposeBag()
    
    
    private let downloadStatusImage: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        
        v.widthAnchor.constraint(equalToConstant: 20).isActive = true
        v.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        
        v.contentMode = .scaleAspectFit
        v.layer.cornerRadius = 10
        v.backgroundColor = UIColor.white
        
        v.image = UIImage(named: "ic_download_new")
        v.clipsToBounds = true
        
        return v
    }()
    
    
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
    
    private func addConstraintsForResendButton() {
        let smallPadding = MessageCellConstant.smallPadding
        
        let topC = NSLayoutConstraint(item: resendButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        //        let botC = NSLayoutConstraint(item: resendButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        let rightC = NSLayoutConstraint(item: resendButton, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: smallPadding)
        
        addConstraints([topC, rightC])
    }
    
    override func prepareUI() {
        // Do UI setup
        self.addSubview(container)
        self.addSubview(resendButton)
        addConstraintsForResendButton()
        addConstraintForFileName()
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        layoutIfNeeded()
        
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
    }
    
    private let timeContent: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isUserInteractionEnabled = false
        tv.textColor = UIColor.black
        tv.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0)
        tv.clipsToBounds = false
        tv.isScrollEnabled = false
        tv.sizeToFit()
        tv.font = UIFont.systemFont(ofSize: 10.0)
        tv.textContainerInset = .zero
        return tv
    }()
    
    private let textContent: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isUserInteractionEnabled = false
        tv.textColor = UIColor.black
        tv.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0)
        tv.clipsToBounds = false
        tv.isScrollEnabled = false
        tv.sizeToFit()
        tv.font = UIFont.boldSystemFont(ofSize: 15.0)
        tv.textContainerInset = .zero
        tv.text = "Testing text view lalalala. And this is a long long text. I want to make it longer and longer. "
        return tv
    }()
    
    private let container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(red: 221.0 / 255.0, green: 234.0 / 255.0, blue: 1, alpha: 1)
        v.layer.cornerRadius = 16.0
        return v
    }()
    
    private func addConstraintForFileName() {
        let normalPadding = MessageCellConstant.normalPadding
        let smallPadding = MessageCellConstant.smallPadding
        let mainPadding = MessageCellConstant.mainPadding
        
        let topC = NSLayoutConstraint(item: container, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: smallPadding)
        let botC = NSLayoutConstraint(item: container, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: smallPadding * -1)
        let leftC = NSLayoutConstraint(item: container, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leading, multiplier: 1, constant: mainPadding)
        let rightC = NSLayoutConstraint(item: container, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: normalPadding * -1)
        
        addConstraints([topC, botC, leftC, rightC])
        
        let topC2 = NSLayoutConstraint(item: textContent, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 8)
        let leftC2 = NSLayoutConstraint(item: textContent, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 12)
        let rightC2 = NSLayoutConstraint(item: textContent, attribute: .trailing, relatedBy: .equal, toItem: downloadStatusImage, attribute: .leading, multiplier: 1, constant: 12 * -1)
        
        let topC3 = NSLayoutConstraint(item: timeContent, attribute: .top, relatedBy: .equal, toItem: textContent, attribute: .bottom, multiplier: 1, constant: 4)
        let leftC3 = NSLayoutConstraint(item: timeContent, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 12)
        let rightC3 = NSLayoutConstraint(item: timeContent, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: container, attribute: .trailing, multiplier: 1, constant: 12 * -1)
        
        let botC2 = NSLayoutConstraint(item: timeContent, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1, constant: 8 * -1)
        
        let topC4 = NSLayoutConstraint(item: downloadStatusImage, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 16
        )
         let rightC4 = NSLayoutConstraint(item: downloadStatusImage, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: 12 * -1)
        
        container.addSubview(textContent)
        container.addSubview(timeContent)
        container.addSubview(downloadStatusImage)
        container.addConstraints([topC2, botC2, leftC2, topC4, rightC4,
                                  rightC2, topC3, leftC3, rightC3])
    }
}

