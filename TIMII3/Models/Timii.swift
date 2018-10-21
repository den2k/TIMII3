//
//  Timii.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/14/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

import Foundation

struct Timii: Firestoreable, Nameable, Owner
{
    var FSCollectionName: FSCollectionName { return .Timers }
    var name: String
    var description: String
    
    func FSSave()
    {
        /*
         Members : memberID
            Timers : timerID
                “name”: “History”
                “description”: “AVHS HIS204”
                “createdDate”: timeStamp
        */
 
        print("Saving new Timii.")
        let db = FS()
        let dict = [
            "name": self.name,
            "description": self.description]
        
        db.FSSaveMemberCollectionDict(collectionName: self.FSCollectionName, dictionary: dict)
//        print(dict)
    }
}
