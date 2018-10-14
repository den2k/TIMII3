//
//  Firestoreable.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/11/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

import Firebase

protocol Firestoreable
{
    var FSCollectionName: CollectionName    { get }     // Members or ...
}

enum CollectionName: String
{
    case Members = "Members"
    case Timers = "Timers"
}

struct FS: Firestoreable
{
    var FSCollectionName: CollectionName
    
    init(collectionName: CollectionName)
    {
        self.FSCollectionName = collectionName
    }
    
    func FSSave(collectionName: CollectionName, dictionary: Dictionary<String,Any>)
    {
        /*
         This function uses Firestore to store information.
         
         8.14.18
         The behavior for system Date objects stored in Firestore is going to change AND YOUR
         APP MAY BREAK. To hide this warning and ensure your app does not break, you need to add
         the following code to your app before calling any other Cloud Firestore methods:
         With this change, timestamps stored in Cloud Firestore will be read back as Firebase
         Timestamp objects instead of as system Date objects. So you will also need to update code
         expecting a Date to instead expect a Timestamp. For example:
         
         old:
         let date: Date = documentSnapshot.get("created_at") as! Date
         
         new:
         let timestamp: Timestamp = documentSnapshot.get("created_at") as! Timestamp
         let date: Date = timestamp.dateValue()
         */
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let rootRef = db.collection(collectionName.rawValue)
        
        // Get logged in Member ID
        guard let UID = Auth.auth().currentUser?.uid else { return }
        
        /*
         10.13.17
         
         - /Counts/Members/325346
         - /Members/<UID>/
            - name: email
            - description: enter a description
            - ...
         */

        rootRef.document(UID).setData(dictionary) { (error) in
            if let error = error {
                print("Oh no! \(error.localizedDescription)")
            } else {
                print("Data has been saved!")
            }
        }
    }
}
