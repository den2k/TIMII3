//
//  DashboardScreenViewController.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/29/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/*

 TODO: 11.4.18 [DONE 11.17.18] - Fix LayoutLoading conflicts errors when adding the following commented out code in this VC. This was fixed after Layout fixed a race condition in the library.  A new release 0.6.33 was committed to the Layout repository due to this bug.
 
 
 TODO: 11.4.18 - Adding a whole code block in viewDidLoad() just to retrive member info...Would like to refactor this into Firestoreable
 */

import UIKit
import Layout
import Firebase

class DashboardScreenViewController: UIViewController, Ownable, LayoutLoading
{
 
    // For a view or controller whose layout is loaded by another class (like BoxesViewController) you can override the layoutNode property and add your own didSet handler.

    @IBOutlet var DashboardScreenNode: LayoutNode?
    {
        didSet
        {
            // Set FS fields to "blank" so no errors show up waiting for data retrival
            // 11.4.18 - added isTimerRunning..... should not need to.
            DashboardScreenNode?.setState([
                "userName": ""
            ])
        }
    }

//    @IBOutlet var userNameLabel: LayoutNode?
    var listenerDash: ListenerRegistration!
  
    /*
     This viewWillAppear plus the addSnapshotListener seems to be updating the value
     for member values all the time!
     */
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // FS Boilerplate to remove warning.
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings

        let memberRef = db.collection(FSCollectionName.Members.rawValue).document(memberID)
        
        print("memberID: --> \(memberID)")      // delete
        
        listenerDash = memberRef.addSnapshotListener { (document, error) in
            guard let doc = document, doc.exists else { return }
            if let err = error {
                print("Error getting document: \(err)")
            } else {
                let memberDoc = document?.data()
                let userName         = memberDoc!["userName"] as? String ?? ""
                // let memberID            = document?.documentID
                // let memberAuthMethod    = memberDoc!["authMethod"] as? String ?? ""

                self.DashboardScreenNode?.setState([
                    "userName": userName
                ])
            }
        }
        
        // Observe for .didNewUserLogin so as to reload this Screen
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadScreen), name: .didNewUserLogin, object: nil)
        
        
    }

//    @objc func reloadScreen()
//    {
//        print("Reloading DashboardScreen.")
//        DispatchQueue.main.async {
//            self.reloadLayout()
//        }
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listenerDash.remove()   // removes listener to present memory hog, network access and also no need for weak reference in definition
    }
}
