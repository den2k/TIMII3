//
//  Timii.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/14/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/*

 11.3.18 - Changed Timii from struct to a class. I'm constantly changing the values within the Timii object and thus passing Timii around as a referencable object and not a value object is the correct definition....
 
 
 TODO: 11.24.18 [DONE 11.25.18] - Add Notification observers for 'didEnterBackground' / 'willEnterforeground' for each timii instance created.
 TODO: 11.25.18 [DONE 12.9.18] - Remove notification observers when a Timii is dealloc

 */

import UIKit

class Timii: Firestoreable, Nameable, Ownable
{
    // Protocol properties
    var FSCollectionName: FSCollectionName { return .Timers }
    var name: String                    = ""
    var description: String             = ""
    
    // Addtional struct properties
    var hours: String                   = "00"
    var minutes: String                 = "00"
    var seconds: String                 = "00"
    var timerCount: Double              = 0
    var timerAccuracy                   = 0.1               // tenth of a second accuracy
    var tempTimer                       = Timer()           // temporary holder per Timii
    var isTimerRunning                  = false             // Timer is NOT running
    var startTime: Date                 = Date()            // holds the start time of a timed session
    var endTimeInterval: DateInterval   = DateInterval()    // holds the end time of a timed session
    var pauseTimerDate                  = Date()            // temporary holder of the timer value in case of suspened to background
    var numOfSessions                   = 0
    var loggedTotalTime: Double         = 0
    var timerID: String                 = ""               // holds Firestore generated document ID
    
    init() {}
    
    init(name: String, description: String)
    {
        self.name = name
        self.description = description
        
        // 12.9.18
        // Notification for when the Application moves to the Background or Foreground
        // Do notification center observers belong in an initializer? For now this is done so
        // if the app goes into the background, running timer values are saved.
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "onDidEnterBackground"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "onWillEnterForeground"), object: nil)
    }
}
