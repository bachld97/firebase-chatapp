//
//  StrangerTableViewCell.swift
//  Messaging
//
//  Created by CPU12071 on 9/5/18.
//  Copyright © 2018 Le Duy Bach. All rights reserved.
//

import UIKit

class StrangerContactCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var avaImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func bind(item: ContactItem) {
        nameLabel.text = item.contact.userName
        idLabel.text = item.contact.userId
        let avaUrl = item.contact.userAvatarUrl
        if avaUrl != nil {
            ImageLoader.load(urlString: avaUrl!, into: self.avaImageView)
        }
    }
}
