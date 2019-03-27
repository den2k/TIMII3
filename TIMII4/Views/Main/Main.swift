//
//  Main.swift
//  TIMII3
//
//  Created by Dennis Huang on 4/15/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

// MARK: ----- TODO -----
// TODO: 10.14.18 - Show Dashboard Screen always even in logout/login
// TODO: 8.23.18 [DONE 10.11.18] - prefersStatusBarHidden for iPhone X does not work. setneedstatusbar, hiding navbar also related to this 'fix' This code was added to deal with X but its not working. This was 'fixed' by adding a standard Lauch Screen.storyboard
// TODO: 10.10.18 [DONE 10.10.18] - Migrated code from TIMII to TIMII3
// TODO: 1.19.19 - Mask TabBarItem so white space doesn't trigger a button press - Eaton


import UIKit
import Layout

class Main: UIViewController, LayoutLoading, UITabBarControllerDelegate
{
    // MARK: ----- GLOBAL CONSTANTS -----
    let MAXNUMOFTIMERS = 9

    
    private var selectedTab = 0     // Set to TimelineScreen
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let login = Login()
        let signedIn = login.isLoggedIn()
        if !signedIn
        {
            perform(#selector(presentLogin), with: nil, afterDelay: 0)
//            self.loadLayout( named: "Main.xml" )
        } else {

            // go to dashboard....??
            
        }
        // 10.14.18 - Borrowed from TIMII/Firebase implementation. Is this needed?
        // 8.7.18 - Add this to MainVC and just do this once after reseting the database to Zero Node
        // then comment out. These setup the Countable Global variables.
        // SetupSystem().GlobalServiceSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadLayout( named: "Main.xml" )
    }
    
    @objc func presentLogin()
    {
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
