//
//  ConversationViewController.swift
//  Messaging
//
//  Created by CPU12071 on 8/30/18.
//  Copyright © 2018 Le Duy Bach. All rights reserved.
//

import UIKit

class SeeConversationVC: UIViewController {
    
    class func instance() -> UIViewController {
        return SeeConversationVC()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addImg = UIImage(named: "ic_add")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: addImg,
                                                                 style: .plain,
                                                                 target: nil,
                                                                 action: nil)
    }
}
