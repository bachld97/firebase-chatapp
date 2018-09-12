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
        let lastMess : String
        let convo = convoItem.conversation
        if (!convo.fromMe) {
            lastMess = convoItem.conversation
                .nickname[convo.lastMess.data["sent-by"]!]! + ": "
        } else {
            lastMess = "You: "
        }
        lastMessContentLabel.text = lastMess + convo.lastMess.data["content"]!
        timeLabel.text = convo.lastMess.data["at-time"]
        
        let tem = convo.id.split(separator: " ")
        var myString: String!
        if tem[0].elementsEqual(convo.myId) {
            myString = String(tem[1])
        } else {
            myString = String(tem[0])
        }
        convoNameLabel.text = convoItem.conversation.nickname[myString]
    }
}
