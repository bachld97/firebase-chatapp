import UIKit
import Kingfisher

class _ImageLoader {
    func loadImage(url urlString: String, into imgView: UIImageView) {
        imgView.kf.cancelDownloadTask()
        let url: URL?
        if urlString.starts(with: "http") {
            url = URL(string: urlString)
        } else {
            url = URL(fileURLWithPath: urlString)
        }
        
        imgView.kf.setImage(with: url)
    }
    
    
    func loadMessageImage(url urlString: String, id: String, into imgView: UIImageView) {
        imgView.kf.cancelDownloadTask()
        let url: URL?
        if urlString.starts(with: "http") {
            // Check if we have a local file for this image
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let dirUrl = NSURL(fileURLWithPath: path)
            if let pathComponent = dirUrl.appendingPathComponent("\(id)") {
                let filePath = pathComponent.path
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filePath) {
                    url = URL(fileURLWithPath: filePath)
                } else {
                    // TODO: save that image to this location for later use?
                    url = URL(string: urlString)
                }
            } else {
                url = URL(string: urlString)
            }
        } else {
            url = URL(fileURLWithPath: urlString)
        }
        imgView.kf.setImage(with: url)
    }
}
