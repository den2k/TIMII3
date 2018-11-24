//
//  Timii.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/14/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/*

 11.3.18 - Changed Timii from struct to a class. I'm constantly changing the values within the Timii object and thus passing Timii around as a referencable object and not a value object is the correct definition.
 */

import Foundation

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
    
    init(name: String, description: String)
    {
        print("Initializing new Timii.")
        self.name           = name
        self.description    = description
        FSSave()        // Creates a new Timer for the first time.
    }
    
}
