//
//  ProfileViewController.swift
//  Messaging
//
//  Created by CPU12071 on 8/30/18.
//  Copyright © 2018 Le Duy Bach. All rights reserved.
//

import UIKit

class SeeProfileVC : UIViewController {
    
    class func instance() -> UIViewController {
        return SeeProfileVC()
    }
    
    init() {
        super.init(nibName: "SeeProfileVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Profile"
        
        
        let logOutImg = UIImage(named: "ic_logout")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: logOutImg,
                                                                 style: .plain,
                                                                 target: nil,
                                                                 action: nil)
    }
}
