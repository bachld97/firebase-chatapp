import Foundation
import UIKit
import AVKit

class VideoPlayerVC: BaseVC {
    
    class func instance(url: URL) -> UIViewController {
        return VideoPlayerVC(url: url)
    }
    
    private let url: URL
    
    init(url: URL) {
        self.url = url
        super.init(nibName: "VideoPlayerVC", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player
        
        present(vc, animated: true) {
            player.play()
        }
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

}
