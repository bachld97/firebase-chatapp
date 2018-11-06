import UIKit
import RxSwift

class AudioTimeMessageCell : BaseMessageCell {
    
    private var disposeBag = DisposeBag()
    override func prepareForReuse() {
        self.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    private var container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = true
        v.clipsToBounds = true
        v.backgroundColor = Setting.getCellColor(for: .otherUser)
        
        return v
    }()
    
    override func prepareUI() {
        self.addSubview(container)
        self.addContainerConstraints()
    }
    
    private func addContainerConstraints() {
        
        
    }
}

