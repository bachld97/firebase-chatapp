import Foundation

protocol PickMediaDelegate: class {
    func onMediaItemPicked(mediaItemUrl: URL)
    func onMediaItemPickFail()
}

