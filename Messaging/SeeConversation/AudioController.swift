import Foundation
import AVFoundation

class AudioController {
    
    private var player: AVPlayer? = nil
    private var currentUrl: URL?

    func playAudio(url : URL) {
//        if (currentUrl?.path ?? "").elementsEqual(url.path) {
//            // player?.seek(to: 0)
//            player?.play()
//        }
        
        if player == nil {
            player = AVPlayer(url: url)
            player?.play()
        }

        print(player?.currentTime())
    }
    
    func pauseAudio() {
        player?.pause()
    }
    
    func resumeAudio() {
        player?.play()
    }
}
