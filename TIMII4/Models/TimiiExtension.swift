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
 TODO: 11.19.18 [Delete 12.9.18] - Make Firestore display of values more responsive (real-time). This issue seems to have gone away..
 TODO: 11.24.18 [DONE 11.25.18] - Add background / foreground timer support.
 TODO: 12.9.18 [DONE 12.9.18] - Changed time stamp from Google Firestore to local Date stamp from app.
 TODO: 12.27.18 [DONE 12.27.18] - Update FSSaveSelectedTimerLog() so it uses a generated ID vs timer name.
 TODO: 12.27.18 - Combine FSSaveSelectedTimerLog() and FSUpdateSelectedTimerStats() into 1 FS transaction and not 2 separate function calls.
 
 */


extension Timii
{

// MARK: ---------- TIMII FUNCTIONS ----------
// This section handles user interactions with the timer.
    
    @objc func toggleTimer(timerID: String)
    {
        if isTimerRunning {
            stopTimer(timerID: timerID)
            resetTimer()
        } else {
            startTimer(dateInterval: 0)
        }
    }
    
    private func startTimer(dateInterval: Double)
    {
        print(">>> Starting timer <<<")
        NotificationCenter.default.post(name: .didStartTimer, object: nil, userInfo: nil)
        
        self.tempTimer = Timer.scheduledTimer(timeInterval: timerAccuracy, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
        self.isTimerRunning = true
        
        // Added -dateInterval because resume from background needs to 'add' back time duration in background
        self.startTime = Date(timeIntervalSinceNow: -dateInterval)
    }
    
    private func stopTimer(timerID: String)
    {
        print(">>> Pausing timer <<<")
        NotificationCenter.default.post(name: .didStopTimer, object: nil, userInfo: nil)
        
        tempTimer.invalidate()
        self.isTimerRunning = false
        self.endTimeInterval = DateInterval(start: self.startTime, end: Date())
        
        /*
         11.23.18
         I may need to move both of these 'saves' to Firebase given how slow
         Firestore is for writes.
         */
        
//        print("Timii/timerID: \(timerID)")
        FSSaveSelectedTimerLog(timerID: timerID)            // Just saves the Log session
        FSUpdateSelectedTimerStats(timerID: timerID)        // Update aggregate stats for the Timer
    }
    
    @objc func stopTimerNotificationHandler(_ notification: Notification)
    {
        print("-> TimiiExtension:stopTimerNotificationHandler: ", notification.userInfo?["timerID"] as Any)   // can delete
        let timerID = notification.userInfo?["timerID"] as? String ?? ""
        stopTimer(timerID: timerID)
        resetTimer()
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
// MARK: ---------- FIRESTORE FUNCTIONS ----------
// This section handles the CRUD that comes with timers
    
import Firebase

extension Timii
{
    
    func FSSave(name: String, description: String)
    {
        print("-> FSSave()")    // delete
        
        let timerDict = [
            "name": name,
            "description": description,
            "numOfSessions": 0,
            "loggedTotalTime": 0,
            ] as [String : Any]
        
        // This creates a new timer
        self.timerID = FS().FSSaveMemberCollectionDict(collectionName: .Timers, dictionary: timerDict)
//        print("-->timerID: \(timerID)")
    }
    

    func FSSaveSelectedTimerLog(timerID: String)
    {
        /*
         
         Saves a timer log session
         
         Members : memberID
         [Collection Name] : 'timer ID'
         Logs :
         "startTime":            self.startTime.description,
         "endTimeInterval":      self.endTimeInterval.duration,
         */
        
        print("-> FSSaveSelectedTimerLog()")    // delete
        
        // Create Log ID with time stamp
        let creationDateTime = Date()        // get the current date and time
        let formatter = DateFormatter()     // initialize the date formatter and set the style
        formatter.dateStyle = .medium       // "Oct 8, 2016"
        formatter.timeStyle = .medium       // "10:52:30 PM"
        let creationDateID = formatter.string(from: creationDateTime)  // "Oct 8, 2016, 10:52:30 PM"
        
        let UID = memberID  // from Ownable
        
        let dict = [
            "startTime":            self.startTime.description,
            "endTimeInterval":      self.endTimeInterval.duration,
            ] as [String : Any]
        
        let db = Firestore.firestore()
        let documentPath = "Members/\(UID)/Timers/\(timerID)/Logs/\(creationDateID)"
        let Ref = db.document(documentPath)
        Ref.setData(dict, merge: true)
        { (error) in
            if let error = error {
                print("Oh no! \(error.localizedDescription)")
            } else {
                print("Member data saved! \(Ref.documentID)")
            }
        }
        
        // "Members/<UID>/Timers/<TimerID>/Logs/<LogID>/[dictionary+Timestamp]"
        //        FS().FSSaveMemberDocumentPathDict(documentPath: "Members/\(uid)/Timers/\(self.name)/Logs/\(historyID)", dictionary: dict)
        
    }

    /*
     This function updates statistics related to one specific timer for a Member.
     This function does not update statistics related to all timers for a member.
     */
    func FSUpdateSelectedTimerStats(timerID: String)
    {
        print("-> FSUpdateSelectedTimerStats()")    // delete
        
        /*
         12.27.18
         On 11.23.18 I recorded a note that FS Transactions are super slow. True.
         Documentation states they update one per second.
         
         They operate on once per second. But
         11.23.18
         Writes to Firestore are slow... So using Firebase RT maybe necessary?!
         Write Transactions sometimes fail....Originally this function was a combo timer stats + log save and working
         but I've reduce it to just saving the timer stats. This function can save multiple collections simultaneously
         though one transaction call but these FS transactions feel super slow... 1++ seconds.
         */
        
        // Firestore Initialization
        let db = Firestore.firestore()
        let timerRef: DocumentReference = db.collection("Members").document("\(memberID)/Timers/\(timerID)")
        
        // https://firebase.google.com/docs/firestore/solutions/aggregation
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let timerDocument = try transaction.getDocument(timerRef).data()
                guard var timerData = timerDocument else { return nil }
                
                // Compute new number of sessions
                let numOfSessions = timerData["numOfSessions"] as? Int ?? 0
                let newNumOfSessions = numOfSessions + 1
                
                // Compute new time spent on Task today
                let logTotal = timerData["loggedTotalTime"] as? Double ?? 0
                let newLogTotal = logTotal + self.endTimeInterval.duration
                
                // Set new info --- what is this for?
                timerData["numOfSessions"] = newNumOfSessions
                timerData["loggedTotalTime"] = newLogTotal
                
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
}

// MARK: ---------- FOREGROUND / BACKGROUND FUNCTIONS ----------
// This section controls suspend functions when the APP goes to the background

extension Timii
{
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
}
