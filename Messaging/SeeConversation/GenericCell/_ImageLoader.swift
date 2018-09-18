import UIKit
import Kingfisher

class _ImageLoader {
    func loadImage(url: String, into imgView: UIImageView) {
        imgView.kf.cancelDownloadTask()
        imgView.kf.setImage(with: URL(string: url))
    }
}

