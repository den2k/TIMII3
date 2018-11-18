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
 
 */

import Foundation
import Firebase

extension Timii
{
    // Protocol functions
    func FSSave()
    {
        /*
         Members : memberID
         Timers : timerID
         “name”: “History”
         “description”: “AVHS HIS204”
         “createdDate”: timeStamp
         */
        
        print("Saving new Timii.")
        let db = FS()
        let dict = [
            "name":             self.name,
            "description":      self.description,
            ]
        
        db.FSSaveMemberCollectionDict(collectionName: self.FSCollectionName, dictionary: dict)
        //        print(dict)
    }

    // Protocol functions
    func FSSaveTimerLog()
    {
        /*
         Members : memberID
           - Timers : 'timer name'
               - Logs :
         "startTime":            self.startTime.description,
         "endTimeInterval":      self.endTimeInterval.duration,
         */
        
        print("Saving new Timii history.")
        
        // Create Log ID with time stamp
        let currentDateTime = Date()        // get the current date and time
        let formatter = DateFormatter()     // initialize the date formatter and set the style
        formatter.dateStyle = .medium       // "Oct 8, 2016"
        formatter.timeStyle = .medium       // "10:52:30 PM"
        let historyID = formatter.string(from: currentDateTime)  // "Oct 8, 2016, 10:52:30 PM"
        
        let uid = memberID  // from Ownable

        let db = FS()
        let dict = [
//            "name":             self.name,
//            "hours":            self.hours,
//            "minutes":          self.minutes,
//            "seconds":          self.seconds,
            "startTime":            self.startTime.description,
            "endTimeInterval":      self.endTimeInterval.duration,
//            "isTimerRunning":   self.isTimerRunning,
            ] as [String : Any]
        
        // "Members/<UID>/Timers/<TimerID>/Logs/<LogID>/[dictionary+Timestamp]"
        db.FSSaveMemberDocumentPathDict(documentPath: "Members/\(uid)/Timers/\(self.name)/Logs/\(historyID)", dictionary: dict)
        // print(dict)
    }

    func FSSaveTimerTransaction()
    {
        // This function saves multiple collections simultaneously to maintain data consistency using Firestore Transactions
        
        // Firestore Initialization
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let timerRef: DocumentReference = db.collection("Members").document("\(memberID)/Timers/\(self.name)")
        let logRef: DocumentReference = timerRef.collection("Logs").document()
        
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
                
                // Compute new Log session
                let dict = [
                    "startTime":            self.startTime.description,
                    "endTimeInterval":      self.endTimeInterval.duration,
                    ] as [String : Any]
                
                // Create Log ID with time stamp
//                let currentDateTime = Date()        // get the current date and time
//                let formatter = DateFormatter()     // initialize the date formatter and set the style
//                formatter.dateStyle = .medium       // "Oct 8, 2016"
//                formatter.timeStyle = .medium       // "10:52:30 PM"
//                let historyID = formatter.string(from: currentDateTime)  // "Oct 8, 2016, 10:52:30 PM"
                
                // Set new info
                timerData["numOfSessions"] = newNumOfSessions
                timerData["loggedTotal"] = newLogTotal
                
                // Commit to Firestore
                transaction.setData(timerData, forDocument: timerRef, merge: true)
                transaction.setData(dict, forDocument: logRef, merge: true)
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
        
    @objc func toggleTimer()
    {
        if isTimerRunning {
            stopTimer()
            resetTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer()
    {
        print("Starting timer.")
        self.tempTimer = Timer.scheduledTimer(timeInterval: timerAccuracy, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
        self.isTimerRunning = true
        self.startTime = Date()
    }
    
    private func stopTimer()
    {
        print("Pausing timer.")
        tempTimer.invalidate()
        self.isTimerRunning = false
        self.endTimeInterval = DateInterval(start: self.startTime, end: Date())
//        FSSaveTimerLog()    // Just saves the Log session
        FSSaveTimerTransaction()    // Saves Log session, and aggregate stats for the Timer, ie; number of sessions, logged time Today
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
}
