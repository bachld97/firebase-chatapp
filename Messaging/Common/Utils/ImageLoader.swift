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
}
