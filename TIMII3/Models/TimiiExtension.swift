//
//  TimiiHelper.swift
//  TIMII3
//
//  Created by Dennis Huang on 2/10/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/* ---------- Notes ----------
 
 TODO: 11.3.18 [DONE 11.4.18] Create new function to save Logs of timer activity
 TODO: 11.3.18  Create a function to save aggregated time by day
 
 */

import Foundation

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
         Timers : timerID
         History : historyID
         "name":             self.name,
         "hours":            self.hours,
         "minutes":          self.minutes,
         "seconds":          self.seconds,
         "isTimerRunning":   self.isTimerRunning,
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
            "name":             self.name,
            "hours":            self.hours,
            "minutes":          self.minutes,
            "seconds":          self.seconds,
            "isTimerRunning":   self.isTimerRunning,
            ] as [String : Any]
        
        // "Members/<UID>/Timers/<TimerID>/Logs/<LogID>/[dictionary+Timestamp]"
        db.FSSaveMemberDocumentPathDict(documentPath: "Members/\(uid)/Timers/\(self.name)/Logs/\(historyID)", dictionary: dict)
        // print(dict)
    }

    
    // Struct functions
    @objc func toggleTimer()
    {
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer()
    {
        print("Starting timer.")
        self.tempTimer = Timer.scheduledTimer(timeInterval: timerAccuracy, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
        self.isTimerRunning = true
    }
    
    private func stopTimer()
    {
        print("Pausing timer.")
        tempTimer.invalidate()
        self.isTimerRunning = false
//        updateView()
//        saveTimers()
    }
    
    func resetTimer()
    {
        self.tempTimer.invalidate()
        self.timerCount = 0
        self.hours      = Timii.hours(self.timerCount)
        self.minutes    = Timii.minutes(self.timerCount)
        self.seconds    = Timii.seconds(self.timerCount)
//        updateView()
    }
    

    @objc private func updateTimer()
    {
        self.timerCount += 1
        self.hours      = Timii.hours(self.timerCount)
        self.minutes    = Timii.minutes(self.timerCount)
        self.seconds    = Timii.seconds(self.timerCount)
//        updateView()
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
