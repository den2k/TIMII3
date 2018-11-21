//
//  Member.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/12/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/*
 TODO: 11.4.18 [DONE 11.?.18] - Add username, fullname so I can use this for later...
 TODO: 11.21.18 [DONE 11.21.18] - Added member ID to Member fields and refactored the saving a member function
 */

import Firebase

class Member: Firestoreable, AuthMethod, Ownable
{
    // Protocol properties
    var FSCollectionName: FSCollectionName { return .Members }
    var email: String = ""
    var memberFields: [String:String] = [:]
    
    // Class properties
    var fullName: String = ""
    var userName: String = ""
    
    // default initializer without any properties. Mainly for testing I guess.
    init() {}
    
    // initializer with email
    init(email: String, fullName: String, userName: String)
    {
        self.email = email
        self.fullName = fullName
        self.userName = userName
    }
    
    // Protocol functions
    func FSSave()
    {
        let dict = [
            "email":            self.email,
            "fullName":         self.fullName,
            "userName":         self.userName,
            "authMethod":       authMethod.rawValue,
            ]
        
        FS().FSSaveMember(userName: self.userName, dictionary: dict)
    }
    
}
