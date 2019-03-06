//
//  Login.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/10/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

/* --- TODO Section ---
 
 TODO: 10.10.18 [DONE - 10.10.18] - Migrated code from TIMII to TIMII3
 TODO: 10.10.18 - Migrate this code as extension to LoginScreen or Main??
 
 */

import UIKit
import Firebase

class Login
{
    @objc public func handleLogout()
    {
        print("Attempting to logout...")
        do {
            try Auth.auth().signOut()
            print("Signed out!!")
            NotificationCenter.default.post(name: .didMemberLogout, object: nil)
            
        } catch let logoutError {
            print(logoutError)
        }
    }
    
    func isLoggedIn() -> Bool
    {
        print("Checking if user is login...")
        if Auth.auth().currentUser?.uid == nil
        {
            print("User is not signed in.")
            return false
        }
        else
        {
            print("User is signed in.")
            
            // 1.13.19 - Added this so the post triggers reading of the member information where needed. Without this NC post, VC may not restart as needed like DashboardScreen VC.
            NotificationCenter.default.post(name: .didMemberLogin, object: nil)
            return true
        }
    }
}
