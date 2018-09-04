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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .default
    }
    
    func bind(item: ContactItem) {
        self.fullnameLabel.text = item.contact.userName
        self.usernameLabel.text = item.contact.userId
        
        let avaUrl = item.contact.userAvatarUrl
        if avaUrl != nil {
            imageFromUrl(avaUrl!)
        }
    }
    
    func imageFromUrl(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            URLSession.shared.dataTask(with: request) {(data,response,error) in
                if let imageData = data as Data? {
                    if let img = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            self.avaImageView.image = img
                        }
                    }
                }
            }.resume()
        }
    }
}
