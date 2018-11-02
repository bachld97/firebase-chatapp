import UIKit
import RxSwift

class EmojiCollectionDataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let cellResuseIdentifier = "EmojiCollectionViewCell"
    private var emojiList: [String] = []
    let emojiPublish: PublishSubject<String>
    
    override init() {
        self.emojiPublish = PublishSubject<String>()
        emojiList = [0x1f601, 0x1f602, 0x1f603, 0x1f604, 0x1f605, 0x1f606,
                     0x1f607, 0x1f608,
                     0x1f609, 0x1f60A, 0x1f60B, 0x1f60C, 0x1f60D, 0x1f60F, 0x1f612,
                     0x1f613]
            .map { (hex) -> String in
                let emo = UnicodeScalar(hex)
                return "\(emo!)"
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.emojiList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellResuseIdentifier,
            for: indexPath) as! EmojiCollectionViewCell

        let emoji = self.emojiList[indexPath.item]
        cell.bind(emoji: emoji)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        emojiPublish.onNext(emojiList[indexPath.item].trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
