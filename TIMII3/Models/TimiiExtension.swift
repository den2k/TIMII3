//
//  TimiiHelper.swift
//  TIMII3
//
//  Created by Dennis Huang on 2/10/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/* ---------- Notes ----------
 
 TODO: 11.3.18 [DONE 11.4.18] - Create new function to save Logs of timer activity
 TODO: 11.3.18 [DONE 11.17.18] - Finished adding startTime and endTimeInterval to Logs collection. Create a function to save aggregated time by day
 TODO: 11.17.18 - Save time spent on the same Task for the present day. Need to take total time and calculate per day time spent.
 TODO: 11.17.18 [DONE 11.18.18] - Save the number of sessions for Task
 TODO: 11.18.18 [DONE 11.18.18] - Save total time spent on a task
 TODO: 11.19.18 - Make Firestore display of values more responsive (real-time).
 TODO: 11.24.18 [DONE 11.25.18] - Add background / foreground timer support.
 
 */

import Foundation
import Firebase

extension Timii
{
    // Protocol functions
    func FSSave()
    {
        /*
         Creates a new Timer for the first time with a time stamp
         
         Members / [UID]
            Timers / [name]
                “name”: “History”
                “description”: “AVHS HIS204”
         */
        
        print("Saving new Timii.")
        
        let dict = [
            "name":             self.name,
            "description":      self.description,
            ]
        
        FS().FSSaveNewCollection(collectionName: self.FSCollectionName, docName: self.name, dictionary: dict)
    }

    func FSSaveTimerLog()
    {
        /*
         
         Saves a timer log session
         
         Members : memberID
            [Collection Name] : 'timer name'
            Logs :
                "startTime":            self.startTime.description,
                "endTimeInterval":      self.endTimeInterval.duration,
         */
        
        print("Saving new Timii session information.")
        
        // Create Log ID with time stamp
        let currentDateTime = Date()        // get the current date and time
        let formatter = DateFormatter()     // initialize the date formatter and set the style
        formatter.dateStyle = .medium       // "Oct 8, 2016"
        formatter.timeStyle = .medium       // "10:52:30 PM"
        let historyID = formatter.string(from: currentDateTime)  // "Oct 8, 2016, 10:52:30 PM"
        
        let uid = memberID  // from Ownable

        let dict = [
            "startTime":            self.startTime.description,
            "endTimeInterval":      self.endTimeInterval.duration,
            ] as [String : Any]
        
        // "Members/<UID>/Timers/<TimerID>/Logs/<LogID>/[dictionary+Timestamp]"
        FS().FSSaveMemberDocumentPathDict(documentPath: "Members/\(uid)/Timers/\(self.name)/Logs/\(historyID)", dictionary: dict)
    }

    @objc func toggleTimer()
    {
        if isTimerRunning {
            stopTimer()
            resetTimer()
        } else {
            startTimer(dateInterval: 0)
        }
    }
    
    private func startTimer(dateInterval: Double)
    {
        print("Starting timer.")
        self.tempTimer = Timer.scheduledTimer(timeInterval: timerAccuracy, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
        self.isTimerRunning = true
        
        // Added -dateInterval because resume from background needs to 'add' back time duration in background
        self.startTime = Date(timeIntervalSinceNow: -dateInterval)
    }
    
    private func stopTimer()
    {
        print("Pausing timer.")
        tempTimer.invalidate()
        self.isTimerRunning = false
        self.endTimeInterval = DateInterval(start: self.startTime, end: Date())
        
        /*
         11.23.18
         I may need to move both of these 'saves' to Firebase given how slow
         Firestore is for writes.
         */
        FSSaveTimerLog()            // Just saves the Log session
        FSUpdateTimerStats()        // Update aggregate stats for the Timer
    }
    
    func resetTimer()
    {
        self.tempTimer.invalidate()
        self.timerCount = 0
        self.hours      = Timii.hours(self.timerCount)
        self.minutes    = Timii.minutes(self.timerCount)
        self.seconds    = Timii.seconds(self.timerCount)
    }
    

    @objc private func updateTimer()
    {
        self.timerCount += 1
        self.hours      = Timii.hours(self.timerCount)
        self.minutes    = Timii.minutes(self.timerCount)
        self.seconds    = Timii.seconds(self.timerCount)
    }

    // Returns a formatted string value for time
    static func hours(_ time: TimeInterval) -> String
    {
        let hrs = Int(time) / 3600 % 600 / 10
        return String(format: "%02i", hrs)
    }
    
    static func minutes(_ time: TimeInterval) -> String
    {
        let mins = Int(time) / 60 % 600 / 10
        return String(format: "%02i", mins)
    }
    
    static func seconds(_ time: TimeInterval) -> String
    {
        let secs = Int(time) % 600 / 10
        return String(format: "%02i", secs)
    }
    
    static func tenthSecond(_ time: TimeInterval) -> String
    {
        let tenthSecs = Int(time) % 10
        return String(format: "%01i", tenthSecs)
    }
    
    func FSUpdateTimerStats()
    {
        print("Saving calculated Timer statistics.")
        
        /*
         11.23.18
         Writes to Firestore are slow... So using Firebase RT maybe necessary?!
         Write Transactions sometimes fail....Originally this function was a combo timer stats + log save and working
         but I've reduce it to just saving the timer stats. This function can save multiple collections simultaneously
         though one transaction call but these FS transactions feel super slow... 1++ seconds.
         */
        
        // Firestore Initialization
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let timerRef: DocumentReference = db.collection("Members").document("\(memberID)/Timers/\(self.name)")
        
        // https://firebase.google.com/docs/firestore/solutions/aggregation
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let timerDocument = try transaction.getDocument(timerRef).data()
                guard var timerData = timerDocument else { return nil }
                
                // Compute new number of sessions
                let numOfSessions = timerData["numOfSessions"] as? Int ?? 0
                let newNumOfSessions = numOfSessions + 1
                
                // Compute new time spent on Task today
                let logTotal = timerData["loggedTotal"] as? Double ?? 0
                let newLogTotal = logTotal + self.endTimeInterval.duration
                
                // Set new info --- what is this for?
                timerData["numOfSessions"] = newNumOfSessions
                timerData["loggedTotal"] = newLogTotal
                
                // Commit to Firestore - Merge updates existing documents, but doesn't create..
                transaction.setData(timerData, forDocument: timerRef, merge: true)
            } catch {
                // Error getting timer data
            }
            return nil
        }) { (object, error) in
            if let error = error {
                print("Oh no! \(error.localizedDescription)")
            } else {
                print("Member data saved! \(timerRef.documentID)")
            }
        }
    }

    // MARK: ---------- START / PAUSE APP TO BACKGROUND ----------
    // This section controls suspend functions when the APP goes to the background
    
    @objc func onDidEnterBackground()
    {
        self.pauseTimerDate = Date()
        
        // stops and removes running timer. This is necessary because resuming from background double counts timers...
        self.tempTimer.invalidate()
        
        print("App moved to background! \(Date()) \(self.pauseTimerDate) counter: \(self.timerCount/10)")
        
        // Save temporary timer values to Firebase
        //timer1.FBSaveTimerBackground()
    }
    
    @objc func onWillEnterForeground()
    {
        if self.isTimerRunning == true
        {
            let dateDifference = self.pauseTimerDate.timeIntervalSince(Date())
            
            self.timerCount -= dateDifference * 10      // time intervals in tenth of a second. timeIntervalSince returns negative so it needs to be negatively added
            
            // startTimer needs to be called again when we invalidate the timer before entering the background
            // startTimer needs to be called and not toggleTimer
            self.startTimer(dateInterval: self.timerCount/10)
            
            print("App moved to foreground! \(Date()) \(dateDifference) counter: \(self.timerCount/10)")
        }
        else
        {
            print("App moved to foreground without timer running.")
        }
        
    }

//    func newFSUpdateTimerStats??()
//    {
//        print("Saving calculated Timer statistics.")
//        
//        /*
//         11.23.18
//         Writes to Firestore are slow... So using Firebase RT maybe necessary?!
//         Write Transactions sometimes fail....Originally this function was a combo timer stats + log save and working
//         but I've reduce it to just saving the timer stats. This function can save multiple collections simultaneously
//         though one transaction call but these FS transactions feel super slow... 1++ seconds.
//         */
//        
//        // Firestore Initialization
//        let db = Firestore.firestore()
//        let settings = db.settings
//        settings.areTimestampsInSnapshotsEnabled = true
//        db.settings = settings
//        
//        let timerRef: DocumentReference = db.collection("Members").document("\(memberID)/Timers/\(self.name)")
//        
//        // https://firebase.google.com/docs/firestore/solutions/aggregation
//        // https://firebase.google.com/docs/firestore/manage-data/transactions
//        db.runTransaction({ (transaction, errorPointer) -> Any? in
//            let timerDocument: DocumentSnapshot
//            do {
//                try timerDocument = transaction.getDocument(timerRef)
//            } catch let fetchError as NSError {
//                errorPointer?.pointee = fetchError
//                return nil
//            }
//            
//            // Safely retrieve record from Firestore
//            guard let oldNumOfSessions = timerDocument.data()?["numOfSessions"] as? Int else {
//                let error = NSError(
//                    domain: "AppErrorDomain",
//                    code: -1,
//                    userInfo: [
//                        NSLocalizedDescriptionKey: "Unable to retrieve from snapshot \(timerDocument)"
//                    ]
//                )
//                errorPointer?.pointee = error
//                return nil
//            }
//            
//            // Safely retrieve record from Firestore
//            guard let oldLogTotal = timerDocument.data()?["loggedTotal"] as? Double else {
//                let error = NSError(
//                    domain: "AppErrorDomain",
//                    code: -2,
//                    userInfo: [
//                        NSLocalizedDescriptionKey: "Unable to retrieve from snapshot \(timerDocument)"
//                    ]
//                )
//                errorPointer?.pointee = error
//                return nil
//            }
//            
//            // Compute new number of sessions
//            let newNumOfSessions = oldNumOfSessions + 1
//            let newLogTotal = oldLogTotal + self.endTimeInterval.duration
//            
//            // Set new info
//            guard var timerData = timerDocument.data() else { return nil }
//            timerData["numOfSessions"] = newNumOfSessions
//            timerData["loggedTotal"] = newLogTotal
//            
//            // Commit to Firestore - Merge updates existing documents, but doesn't create..
//            transaction.setData(timerData, forDocument: timerRef, merge: true)
//            return nil  // where is this returning to?
//        }) { (object, error) in
//            if let error = error {
//                print("Error updating Timer stats: \(error.localizedDescription)")
//            } else {
//                print("Member data saved! \(timerRef.documentID)")
//            }
//        }
//    }

}
