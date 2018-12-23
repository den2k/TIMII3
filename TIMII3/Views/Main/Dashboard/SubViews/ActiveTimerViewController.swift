//
//  ActiveTimerViewController.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/29/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/*
 
 TODO: 11.3.18 [DONE - 12.8.18] - delete testing VC properties timer1
 TODO: 11.3.18 [DONE - 11.3.18] - Save time results to Firestore
 TODO: 11.18.18 - Refactor getTimerStats to somwhere else so we can remove Firebase code from this VC.
 TODO: 12.9.18 - Add isTimerActive / ActiveTimer functions and delete all timer1 placeholder timer code.
 TODO: 12.9.18 - Fix getTimerStats as its not reacing ActiveTimer info and saves data to the wrong place.
 
 */

import UIKit
import Layout
import Firebase

class ActiveTimerViewController: UIViewController, Ownable
{
    // Timers Array
    var timers: [Timii] = []
    
    // ViewController properties
//    var timer1 = Timii()
    
    var timer1 = Timii(name: "History", description: "History 101 for Ellie")

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
                "numOfSessions"     : timer1.numOfSessions,
                "loggedTotalTime"   : timer1.loggedTotalTime,
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showTimer), name: .didSelectNewActiveTimer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(killTimer), name: .didDeselectActiveTimer, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        getTimerStats()
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: (#selector(updateView)), userInfo: nil, repeats: true)
    }

    func getTimerStats()
    {
        // FS Boilerplate to remove warning.
        let db = Firestore.firestore()
//        let settings = db.settings
//        settings.areTimestampsInSnapshotsEnabled = true
//        db.settings = settings
        
        let timerRef = db.collection("Members").document(memberID).collection("Timers").document(timer1.name)
        listenerDash = timerRef.addSnapshotListener { (document, error) in
            guard let doc = document, doc.exists else { return }
            if let err = error {
                print("Error getting document: \(err)")
            } else {
                let timerDoc = document?.data()
                let retNumOfSessions   = timerDoc!["numOfSessions"] as? Int ?? 0
                let retLoggedTotalTime     = timerDoc!["loggedTotalTime"] as? Double ?? 0
                
                // Convert Double to Time
                let hrs = Timii.hours(retLoggedTotalTime*10)
                let min = Timii.minutes(retLoggedTotalTime*10)
                let sec = Timii.seconds(retLoggedTotalTime*10)
                
                self.ActiveTimerNode?.setState([
                    "numOfSessions": retNumOfSessions,
                    "loggedTotalTime": "\(hrs):\(min):\(sec)",
                    ])
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        listenerDash.remove()   // removes listener to present memory hog, network access and also no need for weak reference in definition
        
        NotificationCenter.default.removeObserver(self, name: .didSelectNewActiveTimer, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didDeselectActiveTimer, object: nil)
    }
    
}

//MARK: ---------- Show Timer ----------
extension ActiveTimerViewController
{
    
    @objc func showTimer(_ notification: Notification)
    {
        let index: Int = notification.userInfo?["index"] as? Int ?? 0
        let timerID: String = notification.userInfo?["timerID"] as? String ?? ""
        print("received index: \(index) \(timerID)")
        getTimer(timerID: timerID)
    }
    
    @objc func getTimer(timerID: String)
    {
        let db = Firestore.firestore()
        db.collection("Members").document(memberID).collection("Timers").document(timerID).getDocument()
        { (document, error) in
            if let err = error {
                print("Error getting document: \(err)")
            } else {
                let timerDoc = document?.data()
                print("timerID: \(timerID)")
                print(document?.data() as Any)
                let timerName = timerDoc!["name"] as? String ?? ""
                let timerDesc = timerDoc!["description"] as? String ?? ""
//                let timerCreatedTime = timerDoc!["createdTime"] as?
                
                
                self.timer1.name = timerName
                self.timer1.description = timerDesc
            }
        }
        
    }
    
}

//MARK: ---------- Kill Timer ----------
extension ActiveTimerViewController
{
    
    @objc func killTimer()
    {
        print("Kill timer")
    }
    
}

