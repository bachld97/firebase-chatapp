//
//  ContactTableViewCell.swift
//  Messaging
//
//  Created by CPU12071 on 9/4/18.
//  Copyright © 2018 Le Duy Bach. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

    // @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avaImageView: UIImageView!
    private var imageTask: URLSessionTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .default
    }
    
    func bind(item: ContactItem) {
        self.fullnameLabel.text = item.contact.userName
        self.usernameLabel.text = item.contact.userId
        
        let avaUrl = ImageLoader.buildUrl(forUserId: item.contact.userId)

        imageTask?.cancel()
        imageTask = ImageLoader.load(urlString: avaUrl, into: self.avaImageView)
    }
}
