//
//  UIHelper.swift
//  TIMII4
//
//  Created by Dennis Huang on 1/13/19.
//  Copyright © 2019 Autonomii. All rights reserved.
//

import UIKit


extension UIViewController
{
    func didTapHideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
