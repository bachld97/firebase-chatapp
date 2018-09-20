import Foundation
class UUIDGenerator {
    class func newUUID() -> String {
        return String(describing: UUID())
    }
}
