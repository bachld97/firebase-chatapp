import UIKit
import RxSwift

class AudioMessageCell : BaseMessageCell {
    
    override var item: MessageItem! {
        didSet {
            
            guard let audioItem = item as? AudioMessageItem else {
                return
            }
            
            self.updateMusicToggleUI(isPlaying: audioItem.isPlaying)

            self.musicToggleButton.rx.tap
                .asDriver()
                .drive(onNext: { [unowned self] _ in
                    self.handleMusicToggle(audioItem)
                })
                .disposed(by: self.disposeBag)
            
            self.container.rx.tapGesture()
                .when(.ended)
                .asDriverOnErrorJustComplete()
                .drive(onNext: { [unowned self] _ in
                    self.handleMusicToggle(audioItem)
                })
                .disposed(by: self.disposeBag)
            
            
        }
    }
    
    private func handleMusicToggle(_ audioItem: AudioMessageItem) {
        audioItem.isPlaying = !audioItem.isPlaying
        self.clickPublish?.onNext(self.item)
        self.updateMusicToggleUI(isPlaying: audioItem.isPlaying)
    }
    
    private var disposeBag = DisposeBag()
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    
    private var container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = true
        v.clipsToBounds = true
        v.backgroundColor = Setting.getCellColor(for: .otherUser)
        v.layer.cornerRadius = 16.0

        return v
    }()

    private var musicToggleButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.clipsToBounds = true
        b.widthAnchor.constraint(equalToConstant: 24).isActive = true
        b.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        let playImage = UIImage(named: "ic_play")
        b.setImage(playImage, for: .normal)
        return b
    }()
    
    
    private func updateMusicToggleUI(isPlaying: Bool) {
        if isPlaying {
            let pauseImage = UIImage(named: "ic_pause")
            self.musicToggleButton.setImage(pauseImage, for: .normal)
        } else {
            let playImage = UIImage(named: "ic_play")
            self.musicToggleButton.setImage(playImage, for: .normal)
        }

    }
    
    
    override func prepareUI() {
        self.addSubview(container)
        self.addContainerConstraints()
        
        self.container.addSubview(musicToggleButton)
        self.addButtonConstraints()
    }
    
    
    private func addContainerConstraints() {
        let small = MessageCellConstant.smallPadding
        let normal = MessageCellConstant.normalPadding
        let large = MessageCellConstant.mainPadding
        
        let containerTop = NSLayoutConstraint(
            item: self.container, attribute: .top, relatedBy: .equal,
            toItem: self, attribute: .top, multiplier: 1, constant: small)
        let containerBottom = NSLayoutConstraint(
            item: self.container, attribute: .bottom, relatedBy: .equal,
            toItem: self, attribute: .bottom, multiplier: 1, constant: -small)
        let containerLeft = NSLayoutConstraint(
            item: self.container, attribute: .leading, relatedBy: .equal,
            toItem: self, attribute: .leading, multiplier: 1, constant: normal)
        let containerRight = NSLayoutConstraint(
            item: self.container, attribute: .trailing, relatedBy: .lessThanOrEqual,
            toItem: self, attribute: .trailing, multiplier: 1, constant: -large)
        
        self.addConstraints([containerTop, containerBottom, containerLeft, containerRight])
    }
    
    
    private func addButtonConstraints() {
        let padding = MessageCellConstant.normalPadding
        
        let toggleTop = NSLayoutConstraint(
            item: self.musicToggleButton, attribute: .top, relatedBy: .equal,
            toItem: self.container, attribute: .top, multiplier: 1, constant: padding)
        let toggleBottom = NSLayoutConstraint(
            item: self.musicToggleButton, attribute: .bottom, relatedBy: .equal,
            toItem: self.container, attribute: .bottom, multiplier: 1, constant: -padding)
        let toggleLeft = NSLayoutConstraint(
            item: self.musicToggleButton, attribute: .leading, relatedBy: .equal,
            toItem: self.container, attribute: .leading, multiplier: 1, constant: padding)
        let toggleRight = NSLayoutConstraint(
            item: self.musicToggleButton, attribute: .trailing, relatedBy: .lessThanOrEqual,
            toItem: self.container, attribute: .trailing, multiplier: 1, constant: -padding)
        
        self.container.addConstraints([toggleTop, toggleBottom, toggleLeft, toggleRight])
    }
}
