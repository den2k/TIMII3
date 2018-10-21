//
//  Member.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/12/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

import Firebase

struct Member: Firestoreable, AuthMethod, Owner
{
    var FSCollectionName: FSCollectionName { return .Members }
    var email: String

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

protocol Owner
{
    var memberID: String { get }
}

extension Owner
{
    var memberID: String
    {
        // Get Member ID
        let UID = Auth.auth().currentUser?.uid ?? "No member ID."
        return UID
    }
}
