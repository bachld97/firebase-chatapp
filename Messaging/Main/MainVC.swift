//
//  MainViewController.swift
//  Messaging
//
//  Created by CPU12071 on 8/30/18.
//  Copyright © 2018 Le Duy Bach. All rights reserved.
//

import UIKit

class MainVC: UITabBarController {
    
    class func instance() -> UITabBarController {
        return MainVC()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let chatVC = SeeChatHistoryVC.instance()
        let contactVC = SeeContactVC.instance()
        let profileVC = SeeProfileVC.instance()
        
        let chatTab = UINavigationController(rootViewController: chatVC)
        let contactTab = UINavigationController(rootViewController: contactVC)
        let profileTab = UINavigationController(rootViewController: profileVC)
        
        chatTab.tabBarItem.image = UIImage(named: "ic_tab_chat")?.withRenderingMode(.alwaysOriginal)
        chatTab.tabBarItem.selectedImage = UIImage(named: "ic_tab_chat_hl")?.withRenderingMode(.alwaysOriginal)
        chatTab.tabBarItem.title = "Messages"

        contactTab.tabBarItem.image = UIImage(named: "ic_tab_contact")?.withRenderingMode(.alwaysOriginal)
        contactTab.tabBarItem.selectedImage = UIImage(named: "ic_tab_contact_hl")?.withRenderingMode(.alwaysOriginal)
        contactTab.tabBarItem.title = "Contacts"
        
        profileTab.tabBarItem.image = UIImage(named: "ic_tab_personal")?.withRenderingMode(.alwaysOriginal)
        profileTab.tabBarItem.selectedImage = UIImage(named: "ic_tab_personal_hl")?.withRenderingMode(.alwaysOriginal)
        profileTab.tabBarItem.title = "Profile"
        
        self.viewControllers = [chatTab, contactTab, profileTab]
        
        for item in self.tabBar.items! {
            let selectedItem = [NSAttributedStringKey.foregroundColor: UIColor.black]
            item.setTitleTextAttributes(selectedItem, for: .selected)
        }
        
    }

}
