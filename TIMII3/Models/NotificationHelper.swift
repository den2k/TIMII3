//
//  NotificationHelper.swift
//  TIMII3
//
//  Created by Dennis Huang on 12/17/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let didCreateNewTimer = Notification.Name("didCreateNewTimer")
    static let didSelectNewActiveTimer = Notification.Name("didSelectNewActiveTimer")
    static let didDeselectActiveTimer = Notification.Name("didDeselectActiveTimer")
    
//    static let didNewUserLogin = Notification.Name("didNewUserLogin")
}
