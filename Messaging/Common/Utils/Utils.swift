import UIKit

class UrlBuilder {
    public static func load(urlString: String?, into iv: UIImageView) -> URLSessionTask? {
        
        iv.image = nil
//        iv.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)

        if let url = URL(string: urlString!) {
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                if let imageData = data as Data? {
                    if let img = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            iv.image = img
//                            iv.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
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
    
    public static func buildUrl(forMessageId id: String) -> String {
        return "https://firebasestorage.googleapis.com/v0/b/fir-chat-47b52.appspot.com/o/messages%2F\(id)?alt=media"
    }
}

class ConvId {
    public static func get(for user: User, with contact: Contact) -> String {
        return [user.userId, contact.userId].sorted()
            .joined(separator: " ")
    }
    
}

class Type {
    public static func getMessageType(fromString typeString: String) -> MessageType {
        if typeString.elementsEqual("image") {
            return .image
        } else if typeString.elementsEqual("contact") {
            return .contact
        } else if typeString.elementsEqual("location") {
            return .location
        } else {
            return .text
        }
    }

    public static func getMessageTypeString(fromType type: MessageType) -> String {
        switch type {
        case .location: return "location"
        case .image: return "image"
        case .text: return "text"
        case .contact: return "contact"
        }
    }
}

class Converter {
    public static func convertToMessageTime(timestamp: Int64) -> String {
        let converted = NSDate(timeIntervalSince1970: TimeInterval(timestamp / 1000))
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "HH:mm"// "hh:mm a"
        let time = dateFormatter.string(from: converted as Date)
        return time
    }
    
    public static func convertToHistoryTime(timestamp: Int64) -> String {
        let converted = NSDate(timeIntervalSince1970: TimeInterval(timestamp / 1000))
        let today = Date()
        let dateFormatString = getHistoryFormatString(date1: converted as Date, date2: today)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = dateFormatString
        let time = dateFormatter.string(from: converted as Date)
        return time
    }
    
    public static func getHistoryFormatString(date1: Date, date2: Date) -> String {
        let components1 = Calendar.current.dateComponents(in: NSTimeZone.local, from: date1)
        let components2 = Calendar.current.dateComponents(in: NSTimeZone.local, from: date2)
        
        let dateFormatString: String
        
        if components1.day == components2.day &&
            components1.weekOfYear == components2.weekOfYear {
            dateFormatString = SAME_DATE_FORMAT
        } else if components1.weekOfYear == components2.weekOfYear &&
            components1.year == components2.year {
            dateFormatString = SAME_WEEK_FORMAT
        } else if components1.month == components2.month &&
            components1.year == components2.year {
            dateFormatString = SAME_MONTH_FORMAT
        } else if components1.year == components2.year {
            dateFormatString = SAME_YEAR_FORMAT
        } else {
            dateFormatString = DEFAULT_FORMAT
        }
        
        return dateFormatString
    }
    
    public static let SAME_DATE_FORMAT = "HH:mm"
    public static let SAME_WEEK_FORMAT = "EEEE"
    public static let SAME_MONTH_FORMAT = "EE dd"
    public static let SAME_YEAR_FORMAT = "dd MMMM"
    public static let DEFAULT_FORMAT = "dd/MM/yyyy"
}

class Compressor {
    public static func estimatetMultiplier(forSize originalSize: CGSize) -> CGFloat {
        return 0.1 // Dummy value, ease out the up/download time and bandwidth while testing
    }
}

class DictionaryConverter {
    public static func convert(from dict: [String : String]) -> String {
        var res = ""
        
        for (key, value) in dict {
            res.append("\(key):\(value)|")
        }
        
        return res
    }
    
    public static func convert(from formattedString: String) -> [String : String] {
        var res = [String : String]()
        let arr = formattedString.split(separator: "|")
        arr.forEach { (s) in
                if !s.isEmpty {
                let sub = s.split(separator: ":")
                res[String(sub.first!)] = String(sub.last!)
            }
        }
        return res
    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
}
