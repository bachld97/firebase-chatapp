import Foundation


class FileUtil {
    class func fileExists(_ fileName: String) -> Bool {
        let path = getSavePath(for: fileName)
        return FileManager().fileExists(atPath: path)
    }
    
    class func getSavePath(for fileName: String) -> String {
        let path: String = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true).first!
        let url = URL(fileURLWithPath: path).appendingPathComponent(fileName)
        return url.path
    }
    
    class func getSaveUrl(for fileName: String) -> URL {
        let path: String = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true).first!
        let url = URL(fileURLWithPath: path).appendingPathComponent(fileName)
        return url
    }
}
