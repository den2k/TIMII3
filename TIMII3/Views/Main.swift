//
//  Main.swift
//  TIMII3
//
//  Created by Dennis Huang on 4/15/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

/*
 
 TODO: 8.7.18 - Add if/then check for Countables related to SetupSystem
 TODO: 8.7.18 - Show Timeline Screen always even in logout/login
 TODO: 8.23.18 - prefersStatusBarHidden for iPhone X does not work. setneedstatusbar, hiding navbar also related to this 'fix' This code was added to deal with X but its not working.
 TODO: 10.10.18 [DONE 10.10.18] - Migrated code from TIMII to TIMII3
 
 */

import UIKit
import Layout

class Main: UIViewController, LayoutLoading, UITabBarControllerDelegate
{
    private var selectedTab = 0     // Set to TimelineScreen
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let login = Login()
        let signedIn = login.isLoggedIn()
        if !signedIn
        {
            perform(#selector(presentLogin), with: nil, afterDelay: 0)
        }
        
        print("Show Main / Timeline screen.")
        self.loadLayout(
            named: "Main.xml"
        )
        
        // 8.7.18 - Add this to MainVC and just do this once after reseting the database to Zero Node
        // then comment out. These setup the Countable Global variables.
        // SetupSystem().GlobalServiceSetup()
    }
    
    @objc func presentLogin()
    {
        print("Show Login screen.")
        let login = LoginScreen()
        present(login, animated: false, completion: nil)
    }
    
    func layoutDidLoad(_ layoutNode: LayoutNode)
    {
        guard let tabBarController = layoutNode.viewController as? UITabBarController else { return }
        tabBarController.selectedIndex = selectedTab
        tabBarController.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
    {
        guard let index = tabBarController.viewControllers?.index(of: viewController) else { return }
        selectedTab = index
    }
    
}
