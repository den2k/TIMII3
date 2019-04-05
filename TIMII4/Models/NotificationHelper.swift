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
    public static let didStartTimer = Notification.Name("didStartTimer")
    public static let didStopTimer = Notification.Name("didStopTimer")
    public static let onDidPressActiveTimerMenuButton = Notification.Name("onDidPressActiveTimerMenuButton")
    public static let stopTimer = Notification.Name("stopTimer")
    public static let startTimer = Notification.Name("startTimer")

    // MARK: --- MEMBERS Related ---
    public static let didMemberLogin = Notification.Name("didMemberLogin")
    public static let didMemberLogout = Notification.Name("didMemberLogout")
    
}
