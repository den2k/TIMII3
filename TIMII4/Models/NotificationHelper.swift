//
//  NotificationHelper.swift
//  TIMII3
//
//  Created by Dennis Huang on 12/17/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

import Foundation

extension Notification.Name
{
    // MARK: --- TIMERS Related ---
    public static let didCreateNewTimer = Notification.Name("didCreateNewTimer")
    public static let didUpdateExistingTimer = Notification.Name("didUpdateExistingTimer")
    public static let didDeleteExistingTimer = Notification.Name("didDeleteExistingTimer")
    public static let didSelectNewActiveTimer = Notification.Name("didSelectNewActiveTimer")
    public static let didDeselectActiveTimer = Notification.Name("didDeselectActiveTimer")
    public static let didStartTimer = Notification.Name("didStartTimer")    // triggered after the app has started the timer
    public static let didStopTimer = Notification.Name("didStopTimer")      // triggered after the app has stopped the timer
    public static let onDidPressActiveTimerMenuButton = Notification.Name("onDidPressActiveTimerMenuButton")
    public static let stopTimerUserInput = Notification.Name("stopTimerUserInput")    // triggered after the user initiates a stop timer activity
//    public static let startTimer = Notification.Name("startTimer")

    // MARK: --- MEMBERS Related ---
    public static let didMemberLogin = Notification.Name("didMemberLogin")
    public static let didMemberLogout = Notification.Name("didMemberLogout")
    
}
