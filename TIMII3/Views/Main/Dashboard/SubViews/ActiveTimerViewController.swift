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
 TODO: 11.18.18 - Refactor FSReadTimerStats to somewhere else so we can remove Firebase code from this VC.
 TODO: 12.9.18 [DEPRECATED 12.27.18] - Add isTimerActive / ActiveTimer functions and delete all timer1 placeholder timer code.
 TODO: 12.9.18 [DONE 12.27.18] - Fix FSUpdateTimerStats as its not reaching ActiveTimer info and saves data to the wrong place.
 TODO: 12.24.18 - Why is there a Listener AND the scheduleTimer/updateView()? Seems the listener should be converted to a regular read only and not read in real time. As no longer function will change this timer at the same time.
 TODO: 12.24.18 [DONE 12.27.18] - Yes. The didSet calls the updateView() function. If I have a didSet, do I still need the updateView() function? Not if there is a way to call the didSet every 1/2 second like I am doing with the scheduledTimer()
 TODO: 12.27.18 - Logged time shows the whole Double number. Fix it.
 
 */

import UIKit
import Layout
import Firebase

class ActiveTimerViewController: UIViewController, Ownable
{
    let db = Firestore.firestore()
    var timerID: String = ""
    var timer = Timii(name: " ", description: " ")

//    var listenerDash: ListenerRegistration!

    // This is to initialize FS fields to a value so no errors show up waiting for data retrival
    // 10.30.18 - Outlets must be passed to Layout using UIViewControllers. Cannot use class defined UIViews.
    @IBOutlet var ActiveTimerNode: LayoutNode?
    {
        didSet { updateView() }
    }
    
    @IBAction func toggleTimerButton()
    {
        timer.toggleTimer(timerID: timerID)
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
            "name"              : timer.name,
            "hour"              : timer.hours,
            "minute"            : timer.minutes,
            "second"            : timer.seconds,
            "isTimerRunning"    : timer.isTimerRunning,
            "numOfSessions"     : timer.numOfSessions,
            "loggedTotalTime"   : timer.loggedTotalTime,
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
//        // This will not trigger a read of the timer values unless .didSelectNewActivetimer is triggered.
//        if showActiveTimerConsole == true {
//            FSReadTimerStats()
//            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: (#selector(updateView)), userInfo: nil, repeats: true)
//        }
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
//        if showActiveTimerConsole == true {
//            listenerDash.remove()   // removes listener to present memory hog, network access and also no need for weak reference in definition
//        }
        
        NotificationCenter.default.removeObserver(self, name: .didSelectNewActiveTimer, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didDeselectActiveTimer, object: nil)
    }
    
}

// MARK: -------------------- Extensions --------------------

extension ActiveTimerViewController
{
    
    @objc func showTimer(_ notification: Notification)
    {
//        self.showActiveTimerConsole = true
        let index: Int = notification.userInfo?["index"] as? Int ?? 0
        self.timerID = notification.userInfo?["timerID"] as? String ?? ""
        print("ActiveTimerViewController/showTimer() - received notification index: \(index) \(timerID)")
        FSReadTimer(timerID: timerID)
//        FSReadTimerStats(timerID: timerID)  // combined into FSReadTimer
        
        // Trigger the updating of this View every 1/2 second.
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: (#selector(updateView)), userInfo: nil, repeats: true)
    }
    
    
    @objc func killTimer()
    {
        print("ActiveTimerViewController/killTimer()")
//        self.showActiveTimerConsole = false
        
    }
    
}


// MARK: ---------- FIRESTORE FUNCTIONS ----------

extension ActiveTimerViewController
{
    @objc func FSReadTimer(timerID: String)
    {
        db.collection("Members").document(memberID).collection("Timers").document(timerID).getDocument()
            { (document, error) in
                if let err = error {
                    print("Error getting document: \(err)")
                } else {
                    let timerDoc = document?.data()
                    print("ActiveTimerViewController/readTimer() - timerID: \(timerID)")
                    print(document?.data() as Any)
                    let timerName = timerDoc!["name"] as? String ?? ""
                    let timerDescription = timerDoc!["description"] as? String ?? ""
                    let timerNumOfSessions = timerDoc!["numOfSessions"] as? Int ?? 0
                    let timerLoggedTotalTime = timerDoc!["loggedTotalTime"] as? Double ?? 0
                    
                    self.timer.name = timerName
                    self.timer.description = timerDescription
                    self.timer.numOfSessions = timerNumOfSessions
                    self.timer.loggedTotalTime = timerLoggedTotalTime
                    
                    // Convert Double to Time.
                    let hrs = Timii.hours(timerLoggedTotalTime*10)
                    let min = Timii.minutes(timerLoggedTotalTime*10)
                    let sec = Timii.seconds(timerLoggedTotalTime*10)
                    
                    self.ActiveTimerNode?.setState([
                        "numOfSessions": timerNumOfSessions
                        ])

//                    self.ActiveTimerNode?.setState([
//                        "numOfSessions": timerNumOfSessions,
//                        "loggedTotalTime": "\(hrs):\(min):\(sec)",
//                        ])
                }
        }
    }

/*
    func FSReadTimerStats(timerID: String)
    {
        let timerRef = db.collection("Members").document(memberID).collection("Timers").document(timerID)
        listenerDash = timerRef.addSnapshotListener { (document, error) in
            guard let doc = document, doc.exists else { return }
            if let err = error {
                print("Error getting document: \(err)")
            } else {
                print("ActiveTimerViewController/FSReadTimerStats()")
                let timerDoc = document?.data()
                let retNumOfSessions    = timerDoc!["numOfSessions"] as? Int ?? 0
                let retLoggedTotalTime  = timerDoc!["loggedTotalTime"] as? Double ?? 0
                
                self.timer.numOfSessions = retNumOfSessions
                self.timer.loggedTotalTime = retLoggedTotalTime
                
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
*/
    
    func saveTimerLog()
    {
        print("Kill timer")
    }
    

}
