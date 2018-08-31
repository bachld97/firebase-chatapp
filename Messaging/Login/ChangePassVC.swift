//
//  ChangePassViewController.swift
//  Messaging
//
//  Created by CPU12071 on 8/31/18.
//  Copyright © 2018 Le Duy Bach. All rights reserved.
//

import UIKit

class ChangePassVC : BaseVC, ViewFor {
    var viewModel: ChangePassViewModel!
    
    class func instance() -> UIViewController {
        return ChangePassVC()
    }
    
    typealias ViewModelType = ChangePassViewModel
    
    init() {
        super.init(nibName: "ChangePassVC", bundle: nil)
        viewModel = ChangePassViewModel(displayLogic: self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewModel = ChangePassViewModel(displayLogic: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Change password"
    }
}

extension ChangePassVC :  ChangePassDisplayLogic {
    func goBack() {
        
    }
    
    func showFail() {
        
    }
}
