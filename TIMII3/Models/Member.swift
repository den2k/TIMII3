//
//  Member.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/12/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

struct Member: Firestoreable, AuthMethod
{
    var FSCollectionName: String { return "Members" }

    func saveMemberEmail(email: String)
    {
        print("Saving member email.")
        let db = FS(collectionName: self.FSCollectionName)
        let dict = [
            "email": email,
            "authMethod": authMethod.rawValue]
        db.FSSave(collectionName: self.FSCollectionName, dictionary: dict)
    }
}
