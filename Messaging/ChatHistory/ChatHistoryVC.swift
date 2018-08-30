//
//  ChatHistoryViewController.swift
//  Messaging
//
//  Created by CPU12071 on 8/30/18.
//  Copyright © 2018 Le Duy Bach. All rights reserved.
//

import UIKit

class ChatHistoryVC : UIViewController {
    
    class func instance() -> UIViewController {
        return ChatHistoryVC()
    }

    init() {
        super.init(nibName: "ChatVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Messages"
        let addImg = UIImage(named: "ic_add")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: addImg,
                                                                 style: .plain,
                                                                 target: nil,
                                                                 action: nil)
    }
}
