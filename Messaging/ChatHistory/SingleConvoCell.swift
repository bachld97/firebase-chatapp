//
//  SingleTableViewCell.swift
//  Messaging
//
//  Created by CPU12071 on 9/6/18.
//  Copyright © 2018 Le Duy Bach. All rights reserved.
//

import UIKit

class SingleConvoCell: UITableViewCell {

    @IBOutlet weak var convoNameLabel: UILabel!
    @IBOutlet weak var lastMessContentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var avaImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func bind(convoItem: ConversationItem) {
        // convoItem.conversation.lastMess.
    }
}
