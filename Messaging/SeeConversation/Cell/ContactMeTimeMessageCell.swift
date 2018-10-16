import UIKit
import RxSwift

class ContactMeTimeMessageCell : BaseMessageCell {
    override var item: MessageItem! {
        didSet {
            print("DEBUG: \(item.message.getMessageId())")
            
            self.timeContent.text = item.displayTime
            if item.message.isSending {
                // self.resendButton.isHidden = true
                self.container.backgroundColor = UIColor(red: 221.0 / 255.0, green: 190.0 / 255.0, blue: 200 / 255.0, alpha: 1)
            } else {
                if item.message.isFail {
                    // self.resendButton.isHidden = false
                    self.container.backgroundColor = UIColor(red: 80.0 / 255.0, green: 80.0 / 255.0, blue: 200 / 255.0, alpha: 1)
                } else {
                    // self.resendButton.isHidden = true
                    self.container.backgroundColor = UIColor(red: 221.0 / 255.0, green: 234.0 / 255.0, blue: 1, alpha: 1)
                }
            }
            
            guard let contactMs = item.message as? ContactMessage else {
                return
            }
            
            let contact = contactMs.contact
            
            self.contactName.text = contact.userName
            self.contactId.text = contact.userId
            
            let url = UrlBuilder.buildUrl(forUserId: contact.userId)
            self.imageLoader.loadImage(url: url, into: self.contactAva)
            
            self.messageContact.rx.tap
                .asDriver()
                .drive(onNext: { [unowned self] _ in
                    self.clickPublish?.onNext(self.item)
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    private let imageLoader = _ImageLoader()
    private var disposeBag = DisposeBag()
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    private let timeContent: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isUserInteractionEnabled = false
        tv.textColor = UIColor.black
        tv.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        tv.clipsToBounds = true
        tv.isScrollEnabled = false
        tv.sizeToFit()
        tv.font = UIFont.systemFont(ofSize: 10.0)
        tv.textContainerInset = .zero
        return tv
    }()
    
    override func prepareUI() {
        // Do UI setup
        self.addSubview(container)
        self.addSubview(timeContent)
        // Add Constraints for the container
        let smallPadding = MessageCellConstant.smallPadding
        let normalPadding = MessageCellConstant.normalPadding
        let mainPadding = MessageCellConstant.mainPadding
        
        let topC = NSLayoutConstraint(item: container, attribute: .top, relatedBy: .equal,
                                      toItem: self, attribute: .top, multiplier: 1,
                                      constant: smallPadding)
        //        let botC = NSLayoutConstraint(item: container, attribute: .bottom, relatedBy: .equal,
        //                                      toItem: self, attribute: .bottom, multiplier: 1,
        //                                      constant: smallPadding * -1)
        let rightC = NSLayoutConstraint(item: container, attribute: .trailing, relatedBy: .equal,
                                       toItem: self, attribute: .trailing, multiplier: 1,
                                       constant: normalPadding * -1)
        
        let leftC = NSLayoutConstraint(item: container, attribute: .leading, relatedBy: .greaterThanOrEqual,
                                        toItem: self, attribute: .leading, multiplier: 1,
                                        constant: mainPadding)
        
        addConstraints([topC, leftC, rightC])
        
        container.addSubview(contactAva)
        container.addSubview(contactName)
        container.addSubview(contactId)
        //container.addSubview(messageContact)
        
        addConstraintsForImage()
        addConstraintsForName()
        addConstraintsForId()
        addConstraintsForSendMess()
        addConstraintsForTime()
        
        
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
        
        layoutIfNeeded()
    }
    
    private func addConstraintsForTime() {
        let mainPadding = MessageCellConstant.mainPadding
        let smallPadding = MessageCellConstant.smallPadding
        
        let topC = NSLayoutConstraint(item: timeContent, attribute: .top, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1, constant: smallPadding)
        let leftC = NSLayoutConstraint(item: timeContent, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 4)
        let rightC = NSLayoutConstraint(item: timeContent, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self, attribute: .trailing, multiplier: 1, constant: mainPadding * -1)
        let botC = NSLayoutConstraint(item: timeContent, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: smallPadding * -1)
        
        self.addConstraints([topC, leftC, rightC, botC])
    }
    
    private let contactName: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isUserInteractionEnabled = false
        tv.textColor = UIColor.black
        tv.backgroundColor = UIColor.clear
        tv.clipsToBounds = false
        tv.isScrollEnabled = false
        tv.sizeToFit()
        tv.font = UIFont.boldSystemFont(ofSize: 14.0)
        tv.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        tv.textContainerInset = .zero
        tv.text = "User not available"
        return tv
    }()
    
    private let contactId: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isUserInteractionEnabled = false
        tv.textColor = UIColor.black
        tv.backgroundColor = UIColor.clear
        tv.clipsToBounds = false
        tv.isScrollEnabled = false
        tv.sizeToFit()
        tv.font = UIFont.systemFont(ofSize: 11.0)
        tv.heightAnchor.constraint(equalToConstant: 18.0).isActive = true
        
        tv.textContainerInset = .zero
        tv.text = "This user has deactivated."
        return tv
    }()
    
    private let contactAva: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 40).isActive = true
        v.widthAnchor.constraint(equalToConstant: 40).isActive = true
        v.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        v.layer.cornerRadius = 20.0
        v.clipsToBounds = true
        return v
    }()
    
    private let messageContact: UIButton = {
        return UIButton()
    }()
    
    private let container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(red: 137 / 255.0, green: 229 / 255.0, blue: 163 / 255.0, alpha: 1)
        v.layer.cornerRadius = 16.0
        //        v.clipsToBounds = true
        return v
    }()
    
    private func addConstraintsForImage() {
        // let mainPadding = MessageCellConstant.mainPadding
        let normalPadding: CGFloat = 8.0
        
        let topC = NSLayoutConstraint(item: contactAva, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: normalPadding)
        let botC = NSLayoutConstraint(item: contactAva, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1, constant: normalPadding * -1)
        let leftC = NSLayoutConstraint(item: contactAva, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 16.0)
        
        botC.priority = UILayoutPriority(rawValue: 999)
        addConstraints([topC, botC, leftC])
    }
    
    private func addConstraintsForName() {
        let normalPadding: CGFloat = 8.0
        
        let topC = NSLayoutConstraint(item: contactName, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 12.0)
        let leftC = NSLayoutConstraint(item: contactName, attribute: .leading, relatedBy: .equal, toItem: contactAva, attribute: .trailing, multiplier: 1, constant: normalPadding)
        let rightC = NSLayoutConstraint(item: contactName, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: 16.0 * -1)
        
        addConstraints([topC, leftC, rightC])
    }
    
    private func addConstraintsForId() {
        let normalPadding: CGFloat = 8.0
        
        let topC = NSLayoutConstraint(item: contactId, attribute: .top, relatedBy: .equal, toItem: contactName, attribute: .bottom, multiplier: 1, constant: 0.0)
        let leftC = NSLayoutConstraint(item: contactId, attribute: .leading, relatedBy: .equal, toItem: contactAva, attribute: .trailing, multiplier: 1, constant: normalPadding)
        let rightC = NSLayoutConstraint(item: contactId, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: 16.0 * -1)
        
        addConstraints([topC, leftC, rightC])
    }
    
    private func addConstraintsForSendMess() {
        
    }
}
