//
//  ActiveTimerMenuPopover.swift
//  TIMII4
//
//  Created by Dennis Huang on 3/16/19.
//  Copyright © 2019 Autonomii. All rights reserved.
//

import UIKit

class ActiveTimerMenuPopover: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let editTimerLabel = UILabel()
        editTimerLabel.frame = CGRect(x:0, y:100, width: 120, height: 120)
        editTimerLabel.text = "Edit Timer"
        editTimerLabel.textAlignment = .center
        editTimerLabel.backgroundColor = UIColor.purple
        editTimerLabel.textColor = UIColor.white
        editTimerLabel.font = UIFont(name: "Avenir Next", size: 14)
        self.view.addSubview(editTimerLabel)
        editTimerLabel.isHidden = false
    }
    
}
