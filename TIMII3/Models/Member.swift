//
//  Member.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/12/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

import Firebase

class Member: Firestoreable, AuthMethod, Ownable
{
    var FSCollectionName: FSCollectionName { return .Members }
    var email: String = ""
    var memberFields: [String:String] = [:]
    
    // default initializer
    init() {}
    
    // initializer with email
    init(email: String)
    {
        self.email = email
    }
    
    func FSSave()
    {
        print("Saving member info.")
        let db = FS()
        let dict = [
            "email": self.email,
            "authMethod": authMethod.rawValue]
        
        // save /Members/<UID>/[dictionary]
        db.FSSaveMemberCollectionDict(collectionName: self.FSCollectionName, dictionary: dict)
    }
}
