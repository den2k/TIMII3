//
//  Timii.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/14/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/*

 11.3.18 - Changed Timii from struct to a class. I'm constantly changing the values within the Timii object and thus passing Timii around as a referencable object and not a value object is the correct definition.
 
 TODO: 11.24.18 [DONE 11.25.18] - Add Notification observers for 'didEnterBackground' / 'willEnterforeground' for each timii instance created.
 
 TODO: 11.25.18 - Remove notification observers when a Timii is dealloc

 */

import UIKit

class Timii: Firestoreable, Nameable, Ownable
{
    // Protocol properties
    var FSCollectionName: FSCollectionName { return .Timers }
    var name: String
    var description: String
    
    // Addtional struct properties
    var hours: String       = "00"
    var minutes: String     = "00"
    var seconds: String     = "00"
    var timerCount: Double  = 0
    var timerAccuracy       = 0.1       // tenth of a second accuracy
    var tempTimer           = Timer()   // temporary holder per Timii
    var isTimerRunning      = false     // Timer is NOT running
    
    var startTime: Date                 = Date()            // holds the start time of a timed session
    var endTimeInterval: DateInterval   = DateInterval()    // holds the end time of a timed session
    
    var pauseTimerDate = Date()     // temporary holder of the timer value in case of suspened to background
    
    init(name: String, description: String)
    {
        print("Initializing new Timii.")
        self.name           = name
        self.description    = description
        FSSave()        // Creates a new Timer for the first time.
        
        // Notification for when the Application moves to the Background or Foreground
        // In #selector(self.action()), self.action() is a method call.
        // You don't want to call the method; you want to name the method. Say #selector(action)
        // instead: lose the parentheses, plus there's no need for the self.
        // #selector(self.nowAction()) --> #selector(nowAction)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

    }
    
}
