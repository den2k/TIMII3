//
//  DashboardScreenViewController.swift
//  TIMII4
//
//  Created by Dennis Huang on 10/29/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/*

 TODO: 11.4.18 [DONE 11.17.18] - Fix LayoutLoading conflicts errors when adding the following commented out code in this VC. This was fixed after Layout fixed a race condition in the library.  A new release 0.6.33 was committed to the Layout repository due to this bug.

 TODO: 11.4.18 - Adding a whole code block in viewDidLoad() just to retrive member info...Would like to refactor this into Firestoreable

 TODO: 12.22.18 [DONE 12.22.18] - Added hideActiveTimer to show and hide the active timer section in the dashboard
 TODO: 12.23.18 - ActiveTimerViewController is hidden but still executes. Bad.

 */

import UIKit
import Layout
import Firebase

class DashboardScreenViewController: UIViewController, Ownable, LayoutLoading
{

    // For a view or controller whose layout is loaded by another class (like BoxesViewController) you can override the layoutNode property and add your own didSet handler.

    var hideActiveTimer: Bool = true

    @IBOutlet var DashboardScreenNode: LayoutNode?
    {
        didSet
        {
            // Set FS fields to "blank" so no errors show up waiting for data retrival
            // 11.4.18 - added isTimerRunning..... should not need to.
            DashboardScreenNode?.setState([
                "userName": "",
                "hideActiveTimer": hideActiveTimer,
            ])
        }
    }

    var listenerDash: ListenerRegistration!

    /*
     This viewWillAppear plus the addSnapshotListener seems to be updating the value
     for member values all the time!
     */
    override func viewDidLoad()
    {
        print("-- DashboardScreen : viewDidLoad() --")    // delete
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(readMember), name: .didMemberLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showTimer), name: .didSelectNewActiveTimer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideTimer), name: .didDeselectActiveTimer, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(hideTimer), name: .didDeleteExistingTimer, object: nil)

        // Do I need this if I have NC for readMember to perform the action of reading a member?
        //  readMember()
    }


    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
//        NotificationCenter.default.addObserver(self, selector: #selector(readMember), name: .didMemberLogin, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(showTimer), name: .didSelectNewActiveTimer, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(hideTimer), name: .didDeselectActiveTimer, object: nil)

        // Do I need this if I have NC for readMember() to perform this action of reading a member?
        readMember()        // once this screen appears you need to trigger a read
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        // 1.13.19 - Might not need this given its weak??? Not sure.  it certainly keeps crashing the APP.
//        listenerDash.remove()   // removes listener to present memory hog, network access and also no need for weak reference in definition

        // Commented this out so Observers aren't turned on an off when VCs show up.
        
//        NotificationCenter.default.removeObserver(self, name: .didMemberLogin, object: nil)
//        NotificationCenter.default.removeObserver(self, name: .didSelectNewActiveTimer, object: nil)
//        NotificationCenter.default.removeObserver(self, name: .didDeselectActiveTimer, object: nil)

    }
}


// MARK: -------------------- Extension --------------------

extension DashboardScreenViewController
{
    @objc func showTimer()
    {
        print("Dashboard/showTimer()")    // delete
        hideActiveTimer = false
        self.DashboardScreenNode?.setState([
            "hideActiveTimer": self.hideActiveTimer,
            ])
    }

    @objc func hideTimer()
    {
        print("Dashboard/hideTimer()")    // delete
        hideActiveTimer = true
        self.DashboardScreenNode?.setState([
            "hideActiveTimer": self.hideActiveTimer,
            ])
    }

}

// MARK: ---------- FIRESTORE FUNCTIONS ----------

extension DashboardScreenViewController
{
    @objc func readMember()
    {
        print("--> readMember()")
        // FS Boilerplate to remove warning.
        let db = Firestore.firestore()
//        let settings = db.settings
//        settings.areTimestampsInSnapshotsEnabled = true
//        db.settings = settings

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
                    "userName": userName,
                    "hideActiveTimer": self.hideActiveTimer,
                    ])
            }
        }
    }
}
