//
//  ActiveTimerViewController.swift
//  TIMII4
//
//  Created by Dennis Huang on 10/29/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/*
 
 Note:
 1.6.19 - This VC is loaded with the showing of the Dashboard VC but is hidden.
 
 
 TODO: 11.3.18 [DONE - 12.8.18] - delete testing VC properties timer1
 TODO: 11.3.18 [DONE - 11.3.18] - Save time results to Firestore
 TODO: 11.18.18 - Refactor FSReadTimerStats to somewhere else so we can remove Firebase code from this VC.
 TODO: 12.9.18 [DEPRECATED 12.27.18] - Add isTimerActive / ActiveTimer functions and delete all timer1 placeholder timer code.
 TODO: 12.9.18 [DONE 12.27.18] - Fix FSUpdateTimerStats as its not reaching ActiveTimer info and saves data to the wrong place.
 TODO: 12.24.18 - Why is there a Listener AND the scheduleTimer/updateView()? Seems the listener should be converted to a regular read only and not read in real time. As no longer function will change this timer at the same time.
 TODO: 12.24.18 [DONE 12.27.18] - Yes. The didSet calls the updateView() function. If I have a didSet, do I still need the updateView() function? Not if there is a way to call the didSet every 1/2 second like I am doing with the scheduledTimer()
 TODO: 12.27.18 [DONE 12.28.18] - Logged time shows the whole Double number. Fix it.
 TODO: 12.28.18 [DONE 1.6.19] - Fixed updating the reading of Sessions after pause timer with delay. Update with Listeners for realtime updates.
 TODO: 12.30.18 [DONE 12.30.18] - timer.scheduled trigger not terminating properly.
 TODO: 1.7.19 [DONE 1.13.19] - Only start updateView when the timer.isTimerRunning is true
 TODO: 1.xx.19 [DONE 1.13.19] - Refactor FSReadTimerStats() so its just one function.
 
 */

import UIKit
import Layout
import Firebase

private let menu = UIImage(named: "Menu")

class ActiveTimerViewController: UIViewController, Ownable
{
    var timerID: String = ""        // this is needed because this VC is loaded but hidden before user selects an active timer
    var timer = Timii(name: " ", description: " ")
    
    // Holds the function for running the timer.scheduledtimer() loop
    var timeLoop: Timer?


    // Holds the loggedTotalTime values in its converted form
    var hrs = ""
    var min = ""
    var sec = ""

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
        
        updateView() // Pause and Start icon text don't update if this not called.
        
        // A hack that waits 2 seconds before doing a read to allow Firestore to have time to perform a write
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
            if self.timer.isTimerRunning == false
            {
                print("-> toggleTimerButton: timer not running.")
                let dict = [
                    "timerID": self.timerID,
                    ] as [String : Any]
                
                let notification = Notification(name: .didSelectNewActiveTimer, object: nil, userInfo: dict)
                self.FSReadTimerStats(notification)
            }
        }
    }
    
    @objc func updateView()
    {
        // Calling setState() on a LayoutNode after it has been created will trigger an update. The update causes all expressions in
        // that node and its children to be re-evaluated.
        
        self.ActiveTimerNode?.setState([
            "name"              : timer.name,
            "hour"              : timer.hours,
            "minute"            : timer.minutes,
            "second"            : timer.seconds,
            "isTimerRunning"    : timer.isTimerRunning,
            "numOfSessions"     : timer.numOfSessions,
            "loggedTotalTime"   : "\(hrs):\(min):\(sec)",
            ])
        
        print("-")   // delete
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(FSReadTimerStats), name: .didSelectNewActiveTimer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FSReadTimerStats), name: .didUpdateExistingTimer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidDeleteActiveTimer), name: .didDeleteExistingTimer, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupUpdateView), name: .didStartTimer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopUpdateView), name: .didStopTimer, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(FSReadTimerStats), name: .didSelectNewActiveTimer, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(setupUpdateView), name: .didStartTimer, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(stopUpdateView), name: .didStopTimer, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)

//        NotificationCenter.default.removeObserver(self, name: .didSelectNewActiveTimer, object: nil)
//        NotificationCenter.default.removeObserver(self, name: .didStartTimer, object: nil)
//        NotificationCenter.default.removeObserver(self, name: .didStopTimer, object: nil)
    }
    
}

// MARK: -------------------- Extensions --------------------

extension ActiveTimerViewController
{
    
    @objc func setupUpdateView(_ notification: Notification)
    {
        print("-> ActiveTimerViewController: setupUpdateView()")
//        self.showActiveTimerConsole = true
//        let index: Int = notification.userInfo?["index"] as? Int ?? 0
//        self.timerID = notification.userInfo?["timerID"] as? String ?? ""
//        print("ActiveTimerViewController/setupUpdateView() - received notification index: \(index) \(timerID)")
//        FSReadTimerStats(timerID: timerID)
        
        // Trigger the updating of this view every 0.25 seconds.
        if timeLoop == nil
        {
            timeLoop = Timer.scheduledTimer(
                timeInterval: 0.25,
                target: self,
                selector: (#selector(updateView)),
                userInfo: nil,
                repeats: true)
        }
    }
    
    
    @objc func stopUpdateView()
    {
        print("-> ActiveTimerViewController: stopUpdateView()")
        
        // Kills the scheduled timer for refreshing the UI
        if timeLoop != nil
        {
            timeLoop?.invalidate()
            timeLoop = nil
        }
    }
    
    @objc func onDidPressMenuButton()
    {
        print("Pressed Menu button.")
        
        let screen = ChangeTimerScreen()

        // Keeps the presenting "ActiveTimerViewController" in view beneath the presented "ChangeTimerScreen" VC.
        screen.modalPresentationStyle = .overFullScreen
        self.present(screen, animated: true, completion: nil)

        // Notification to tell ChangeMenuScreen to start reading the Timer information
        let dict = [
            "timerID": timerID,
            ] as [String : Any]
        NotificationCenter.default.post(name: .onDidPressActiveTimerMenuButton, object: nil, userInfo: dict)

        print("Back to ActiveTimerViewController")
        
    }
    
    @objc func onDidDeleteActiveTimer()
    {
        print("ActiveTimerViewController: Did Deleted Existing Timer.")
    }
    
}


// MARK: ---------- FIRESTORE FUNCTIONS ----------

extension ActiveTimerViewController
{
    @objc func FSReadTimerStats(_ notification: Notification)
    {
        let db = Firestore.firestore()
        
        self.timerID = notification.userInfo?["timerID"] as? String ?? ""
        print("-> FSReadTimerStats( \(timerID) )")   // delete
        db.collection("Members").document(memberID).collection("Timers").document(timerID).getDocument()
        { (document, error) in
            if let err = error {
                print("Error getting document: \(err)")
            } else {
                let timerDoc = document?.data()
//                print("ActiveTimerViewController/readTimer() - timerID: \(timerID)")
//                print(document?.data() as Any)
                let timerName = timerDoc!["name"] as? String ?? ""
                let timerDescription = timerDoc!["description"] as? String ?? ""
                let timerNumOfSessions = timerDoc!["numOfSessions"] as? Int ?? 0
                let timerLoggedTotalTime = timerDoc!["loggedTotalTime"] as? Double ?? 0
                
                self.timer.name = timerName
                self.timer.description = timerDescription
                self.timer.numOfSessions = timerNumOfSessions
                self.timer.loggedTotalTime = Double(timerLoggedTotalTime).rounded()
                
                // Convert Double to Time.
                self.hrs = Timii.hours(timerLoggedTotalTime*10)
                self.min = Timii.minutes(timerLoggedTotalTime*10)
                self.sec = Timii.seconds(timerLoggedTotalTime*10)
                
                self.ActiveTimerNode?.setState([
                    "name":             self.timer.name,
                    "numOfSessions":    timerNumOfSessions,
                    "hour":             self.timer.hours,           // reset to 0? after didSelectNewActiveTimer
                    "minute":           self.timer.minutes,         // reset to 0? after didSelectNewActiveTimer
                    "second":           self.timer.seconds,         // reset to 0? after didSelectNewActiveTimer
                    "loggedTotalTime": "\(self.hrs):\(self.min):\(self.sec)"
                    ])
            }
        }
    }
    
}
