//
//  Member.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/12/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
// 11.4.18 - Add username, fullname so I can use this for later...

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
    
//    func FSSave()
//    {
//        print("Saving member info.")
//        let db = FS()
//        let dict = [
//            "email": self.email,
//            "authMethod": authMethod.rawValue]
//
//        // save /Members/<UID>/[dictionary]
//        db.FSSaveMemberCollectionDict(collectionName: self.FSCollectionName, dictionary: dict)
//    }
    
    
    // Protocol functions
    func FSSave()
    {
        // Members/<uid>/[dict]
        print("Saving member information")
        let db = FS()
        let dict = [
            "email":            self.email,
            "fullName":         self.fullName,
            "userName":         self.userName,
            "authMethod":       authMethod.rawValue,
            ]
        
        // save /Members/<UID>/[dictionary]
        db.FSSaveMemberDict(collectionName: self.FSCollectionName, dictionary: dict)
        //        print(dict)
    }
    
}
