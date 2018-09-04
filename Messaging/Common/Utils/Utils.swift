import UIKit

class ImageLoader {
    public static func load(urlString: String, into iv: UIImageView) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            URLSession.shared.dataTask(with: request) {(data,response,error) in
                if let imageData = data as Data? {
                    if let img = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            iv.image = img
                        }
                    }
                }
                }.resume()
        }
    }
}

