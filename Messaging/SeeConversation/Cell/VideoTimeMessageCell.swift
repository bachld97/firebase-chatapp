import UIKit
import RxSwift

class VideoTimeMessageCell : BaseMessageCell {
    private var disposeBag = DisposeBag()
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override var item: MessageItem! {
        didSet {
            let url = UrlBuilder.buildUrl(
                forThumbnailOf:item.message.getMessageId())
            
            contentImage.rx.tapGesture()
                .when(.ended)
                .asDriverOnErrorJustComplete()
                .drive(onNext: { [unowned self] _ in
                    self.clickPublish?.onNext(self.item)
                })
                .disposed(by: self.disposeBag)
            
            timeContent.text  = item.displayTime
            imageLoader.loadImage(url: url, into: self.contentImage)
        }
    }
    
    private let imageLoader = _ImageLoader()
    
    private let contentImage: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 156.0).isActive = true
        v.widthAnchor.constraint(equalToConstant: 156.0).isActive = true
        v.backgroundColor = UIColor(red: 137 / 255.0, green: 229 / 255.0, blue: 163 / 255.0, alpha: 1)
        v.layer.cornerRadius = 16.0
        v.clipsToBounds = true
        return v
    }()
    
    private let videoPlayImage: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 36.0).isActive = true
        v.widthAnchor.constraint(equalToConstant: 36.0).isActive = true
        // v.backgroundColor = Setting.colorOther
        v.layer.cornerRadius = 18.0
        v.clipsToBounds = true
        v.image = UIImage(named: "ic_video_play")
        return v
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
    
    private var imageTask: URLSessionTask?
    override func prepareUI() {
        self.addSubview(contentImage)
        self.addSubview(timeContent)
        self.addSubview(videoPlayImage)
        
        addConstraintsForPlayImage()
        addConstraintsForImage()
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        layoutIfNeeded()
        
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
    }
    
    
    private func addConstraintsForPlayImage() {
        let iconTop = NSLayoutConstraint(item: videoPlayImage, attribute: .top, relatedBy: .equal, toItem: contentImage, attribute: .top, multiplier: 1, constant: 60)
        let iconLeft = NSLayoutConstraint(item: videoPlayImage, attribute: .leading, relatedBy: .equal, toItem: contentImage, attribute: .leading, multiplier: 1, constant: 60)
        
        self.addConstraints([iconTop, iconLeft])
    }
    
    
    private func addConstraintsForImage() {
        let mainPadding = MessageCellConstant.mainPadding
        let normalPadding = MessageCellConstant.normalPadding
        let smallPadding = MessageCellConstant.smallPadding
        
        let topC = NSLayoutConstraint(item: contentImage, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: smallPadding)
        // let botC = NSLayoutConstraint(item: contentImage, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: smallPadding * -1)
        let leftC = NSLayoutConstraint(item: contentImage, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: normalPadding)
        let rightC = NSLayoutConstraint(item: contentImage, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self, attribute: .trailing, multiplier: 1, constant: mainPadding * -1)
        
        let topC2 = NSLayoutConstraint(item: timeContent, attribute: .top, relatedBy: .equal, toItem: contentImage, attribute: .bottom, multiplier: 1, constant: smallPadding)
        let leftC2 = NSLayoutConstraint(item: timeContent, attribute: .leading, relatedBy: .equal, toItem: contentImage, attribute: .leading, multiplier: 1, constant: 4)
        let rightC2 = NSLayoutConstraint(item: timeContent, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self, attribute: .trailing, multiplier: 1, constant: mainPadding * -1)
        let botC2 = NSLayoutConstraint(item: timeContent, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: smallPadding * -1)
        
        botC2.priority = UILayoutPriority(rawValue: 999)
        addConstraints([topC, leftC, rightC, topC2, leftC2, rightC2, botC2])
    }
}
