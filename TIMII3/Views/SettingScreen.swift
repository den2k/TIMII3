//
//  SettingScreen.swift
//  TIMII
//
//  Created by Dennis Huang on 8/5/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

/* TODO Section
 
 TODO: 8.5.18 - This file exist as the 'controller' (swift class) for our 'views' (XML) that can be referenced using the XML tag (ie; <SettingsScreen>)
 TODO: 8.21.18 - Login out and login back in drop user on to profile/Setting screen given the present call here. Remove the present LoginScreen from the HandleLogout func. This was tried but the present / dismiss / Layout with XML views seems to get in the way. I tried a few ways through main.swift to offload this into the LogInOutSystem.swift without too much luck. At least the Firebase calls from this class is no longer needed.
 TODO: 10.10.18 [DONE 10.10.18] - Migrated code from TIMII to TIMII3
 TODO: 10.21.18 [DONE 10.28.18] - Added Member info to be displayed on Profile screen
 TODO: 10.28.18 - Refresh screen info on a login/logout action.
 TODO: 10.28.18 - Refactor fetchMemberEmail -> to Member.swift file
 
 */

import UIKit
import Layout
import Firebase

class SettingScreen: UIViewController, Ownable
{
    @IBOutlet var SettingScreenNode: LayoutNode? {
        didSet {
            // Initialize Firestore fields to "blank" so there is no errors waiting for the retrival of the data
            SettingScreenNode?.setState(["mEmailLabel": ""])
            fetchMemberEmail()
        }
    }
 
    // 10.28.18 - This function works and sets the state of the variables within the SettingScreenNode layout object
    func fetchMemberEmail()
    {
        // Adding a whole code block just to retrive member info...
        // FS Boilerplate to remove warning.
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let memberRef = db.collection(FSCollectionName.Members.rawValue).document(memberID)
        memberRef.getDocument { (document, error) in
            guard let doc = document, doc.exists else { return }
            if let err = error {
                print("Error getting document: \(err)")
            } else {
                let memberDoc = document?.data()
                let memberEmail         = memberDoc!["email"] as? String ?? ""
                // let memberID            = document?.documentID
                // let memberAuthMethod    = memberDoc!["authMethod"] as? String ?? ""
                
                self.SettingScreenNode?.setState([
                    "mEmailLabel": memberEmail as Any
                    ])
            }
        }
    }
    
    @objc func settingHandleLogout()
    {
        print("Setting Screen logout...")
        let lo = Login()
        lo.handleLogout()
        
        print("Show Login screen from SettingScreen.")
        let login = LoginScreen()
        present(login, animated: true, completion: nil)
    }
}
