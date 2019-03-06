//
//  Ownable.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/28/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

import Firebase

protocol Ownable
{
    var memberID: String { get }
}

extension Ownable
{
    var memberID: String
    {
        // Get Member ID
        let UID = Auth.auth().currentUser?.uid ?? "No member ID."
        return UID
    }
}
