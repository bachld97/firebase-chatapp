//
//  ContactViewController.swift
//  Messaging
//
//  Created by CPU12071 on 8/30/18.
//  Copyright © 2018 Le Duy Bach. All rights reserved.
//

import UIKit

class ContactVC: UIViewController {
    
    class func instance() -> UIViewController {
        return ContactVC()
    }
    
    init() {
        super.init(nibName: "ContactVC", bundle: nil) 
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Contacts"
    }
}
