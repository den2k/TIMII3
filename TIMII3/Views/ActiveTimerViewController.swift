//
//  ActiveTimerViewController.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/29/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/*
 TODO: 11.3.18 - delete testing VC properties timer1
 TODO: 11.3.18 [DONE - 11.3.18] - Save time results to Firestore
 TODO: 11.18.18 - Refactor getTimerStats to somwhere else so we can remove Firebase code from this VC.
 */

import Foundation
import Layout
import Firebase

class ActiveTimerViewController: UIViewController, Ownable
{
    
    // ViewController properties
//    var timer1 = Timii(name: "History", description: "History 101 for Ellie")
    var timer1 = Timii(name: "English", description: "English 201 for Eaton")

    var listenerDash: ListenerRegistration!

    // This is to initialize FS fields to a value so no errors show up waiting for data retrival
    // 10.30.18 - Outlets must be passed to Layout using UIViewControllers. Cannot use class defined UIViews.
    @IBOutlet var ActiveTimerNode: LayoutNode?
    {
        didSet
        {
            ActiveTimerNode?.setState([
                "name"              : timer1.name,
                "hour"              : timer1.hours,
                "minute"            : timer1.minutes,
                "second"            : timer1.seconds,
                "isTimerRunning"    : timer1.isTimerRunning,
                "numOfSessions"     : 0,
                "loggedTotal"       : "0",
            ])
        }
    }
    
    @IBAction func toggleTimerButton()
    {
        timer1.toggleTimer()
        updateView()
    }
    
    @objc func updateView()
    {
        /*
        Calling setState() on a LayoutNode after it has been created
        will trigger an update. The update causes all expressions in
        that node and its children to be re-evaluated.
         */
        
        self.ActiveTimerNode?.setState([
            "name"              : timer1.name,
            "hour"              : timer1.hours,
            "minute"            : timer1.minutes,
            "second"            : timer1.seconds,
            "isTimerRunning"    : timer1.isTimerRunning,
        ])
    }
    
    /*
     This viewWillAppear plus the addSnapshotListener seems to be updating the value
     for member values all the time!
     */
    
    // viewDidLoad is called purely to trigger an updateView of this VC every second  --> tenth of a second
    
    
    override func viewDidLoad()
    {
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: (#selector(updateView)), userInfo: nil, repeats: true)
        getTimerStats()
    }

    func getTimerStats()
    {
        // FS Boilerplate to remove warning.
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let timerRef = db.collection("Members").document(memberID).collection("Timers").document(timer1.name)
        listenerDash = timerRef.addSnapshotListener { (document, error) in
            guard let doc = document, doc.exists else { return }
            if let err = error {
                print("Error getting document: \(err)")
            } else {
                let timerDoc = document?.data()
                let retNumOfSessions   = timerDoc!["numOfSessions"] as? Int ?? 0
                let retLoggedTotal     = timerDoc!["loggedTotal"] as? Double ?? 0
                
                // Convert Double to Time
                let hrs = Timii.hours(retLoggedTotal*10)
                let min = Timii.minutes(retLoggedTotal*10)
                let sec = Timii.seconds(retLoggedTotal*10)
                
                self.ActiveTimerNode?.setState([
                    "numOfSessions": retNumOfSessions,
                    "loggedTotal": "\(hrs):\(min):\(sec)",
                    ])
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        listenerDash.remove()   // removes listener to present memory hog, network access and also no need for weak reference in definition
    }
    
}
