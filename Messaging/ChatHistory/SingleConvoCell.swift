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
//        let senderId = convoItem.conversation.lastMessDict["sent-by"] ?? "Unknown user"
//        convoNameLabel.text = convoItem.conversation.nicknameDict[senderId] ?? senderId
        timeLabel.text = "Hello world"
//        lastMessContentLabel.text = convoItem.conversation.lastMessDict["content"] ?? "No content"
    }
}
