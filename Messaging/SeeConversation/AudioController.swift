import Foundation
import AVFoundation

class AudioController {
    
    private var player: AVPlayer? = nil
    private var currentUrl: URL?
    
    func playAudio(url : URL) {
        if (currentUrl?.path ?? "").elementsEqual(url.path) {
            self.resumeAudio()
        } else  {
            player = AVPlayer(url: url)
            self.currentUrl = url
            player?.play()
        }
    }
    
    func pauseAudio() {
        player?.pause()
    }
    
    func resumeAudio() {
        player?.play()
    }
}
