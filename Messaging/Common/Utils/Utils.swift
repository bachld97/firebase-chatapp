import UIKit

class ImageLoader {
    public static func load(urlString: String?, into iv: UIImageView) -> URLSessionTask? {
        
        iv.image = nil
        iv.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)

        if let url = URL(string: urlString!) {
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                if let imageData = data as Data? {
                    if let img = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            iv.image = img
                            iv.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                        }
                    }
                }
            }
            task.resume()
            return task
        }
        
        return nil
    }
    
    public static func buildUrl(forUserId id: String) -> String {
        return "https://firebasestorage.googleapis.com/v0/b/fir-chat-47b52.appspot.com/o/users%2F\(id)?alt=media"
    }
}

