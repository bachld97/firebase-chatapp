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
    
    private func startAudio(url: URL) {
        stkPlayer?.stop()
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
    
    func stopAudio() {
        stkPlayer?.stop()
        stkPlayer = nil
        currentUrl = nil
    }
}
