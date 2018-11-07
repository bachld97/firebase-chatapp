import Foundation
import StreamingKit

class AudioController {
    
    private var stkPlayer: STKAudioPlayer? = nil
    private var currentUrl: URL?
    
    func playAudio(url : URL) {
        if (currentUrl?.path ?? "").elementsEqual(url.path) {
            self.resumeAudio()
        } else  {
            self.startAudio(url: url)
        }
    }
    
    func startAudio(url: URL) {
        stkPlayer = STKAudioPlayer()
        stkPlayer?.play(url)
        self.currentUrl = url
    }
    
    func pauseAudio() {
        stkPlayer?.pause()
    }
    
    func resumeAudio() {
        stkPlayer?.resume()
    }
}
