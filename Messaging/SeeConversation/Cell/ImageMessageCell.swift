import UIKit

class ImageMessageCell: UITableViewCell {
    
    private var smallPadding: CGFloat = 4
    private var normalPadding: CGFloat = 16
    private var mainPadding: CGFloat = 96

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
    
    private var imageTask: URLSessionTask?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }
    
    private func setUpViews() {
        self.addSubview(contentImage)
        addConstraintsForTextContent()
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        layoutIfNeeded()
        
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
    }
    
    private func addConstraintsForTextContent() {
        let topC = NSLayoutConstraint(item: contentImage, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: smallPadding)
        let botC = NSLayoutConstraint(item: contentImage, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: smallPadding * -1)
        let leftC = NSLayoutConstraint(item: contentImage, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: normalPadding)
        let rightC = NSLayoutConstraint(item: contentImage, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self, attribute: .trailing, multiplier: 1, constant: mainPadding * -1)
        
        addConstraints([topC, botC, leftC, rightC])
    }
    
    func bind(message: Message) {
        imageTask?.cancel()
        imageTask = ImageLoader.load(urlString: message.data["content"]!, into: contentImage)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
}
