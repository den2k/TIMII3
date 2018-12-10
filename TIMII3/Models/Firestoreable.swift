//
//  Firestoreable.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/11/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/*
 
 TODO: 11.25.18 - Change startTime/timestamp from server time to app time
 
 */

import Firebase

protocol Firestoreable
{
    var FSCollectionName: FSCollectionName    { get }     // Members or ...
    func FSSave()       // Every conforming object needs to save info to Firestore
}

enum FSCollectionName: String
{
    // rawValue would give us this String label definition by default but making this explicit
    case Members = "Members"
    case Timers = "Timers"
}

struct FS
{
    func FSSaveMember(userName: String, dictionary: Dictionary<String,Any>)
    {
        /*
         This function saves a newly created Member and the member's personal info
         */
        
        // Firestore Initialization
        let db = Firestore.firestore()
        
        // Create reference variable to save
        guard let UID = Auth.auth().currentUser?.uid else { return }    // Auto-generated Firebase user ID
        let dictUID = ["uid": UID]
        
        // Create time stamp
        let currentDateTime = Date()        // get the current date and time
        let formatter = DateFormatter()     // initialize the date formatter and set the style
        formatter.dateStyle = .medium       // "Oct 8, 2016"
        formatter.timeStyle = .medium       // "10:52:30 PM"
        let timeStamp = formatter.string(from: currentDateTime)  // "Oct 8, 2016, 10:52:30 PM"
        let dictTS = ["createdTime": timeStamp]

        // cannot append to let dictionary thus created a temp dict
        var dict = dictionary
        dict.append(other: dictTS)
        dict.append(other: dictUID)
        
        // Members/[UID] - [user info + Timestamp + UID]/
        let Ref = db.collection(FSCollectionName.Members.rawValue).document(UID)
        Ref.setData(dict, merge: true)
        { (error) in
            if let error = error {
                print("Oh no! \(error.localizedDescription)")
            } else {
                print("Member saved! \(Ref.documentID)")
            }
        }
    }

    func FSSaveNewCollection(collectionName: FSCollectionName, docName: String, dictionary: Dictionary<String,Any>)
    {
        /*
         This function saves a collection tied to a member ID.
         
         /Members/[UID]/[CollectionName]/DocumentName - [dictionary+Timestamp]/
         */
        
        // Firestore Initialization
//        let db = Firestore.firestore()
//        let settings = db.settings
//        settings.areTimestampsInSnapshotsEnabled = true
//        db.settings = settings
        
        // Retrieve Member documentation
        guard let UID = Auth.auth().currentUser?.uid else { return } // Auto-generated Firebase user ID
        let ts = Date().description
        let dictTS =    ["createdTime": ts]
        var dict = dictionary  // cannot append to let dictionary thus created a temp dict1
        dict.append(other: dictTS)
        
        print("FSSaveNewCollection: \(dict)")           // delete
        print("collectionName: \(collectionName)")      // delete
        print("docName: \(docName)")                    // delete
        print("UID: \(UID)")                            // delete

//        db.collection("Members").document(UID)
//            .collection(collectionName.rawValue).addDocument(data: dict)
//                { (error) in
//                if let err = error {
//                    print("Oh no! \(err.localizedDescription)")
//                } else {
//                    print("Member new collection document!")
//                }
//        }
        
        var ref: DocumentReference? = nil
        ref = Firestore.firestore().collection("Members").document(UID)
                                   .collection("Timers").addDocument(data: dict)
            { (error) in
                if let error = error {
                    print("Oh no! \(error.localizedDescription)")
                } else {
                    print("Member new collection document! \(ref!.documentID)")
                }
            }
        print("what?")
    }
    

    func FSSaveMemberCollectionDict(collectionName: FSCollectionName, dictionary: Dictionary<String,Any>)
    {
        /*
         12.9.18 - Updated 
         This function saves a collection tied to a member ID.
         /Members/[UID]/[CollectionName]/CollectionID/[dictionary+Timestamp]
         */
        
        // Firestore Initialization
        let db = Firestore.firestore()

        // Retrieve Member documentation
        guard let UID = Auth.auth().currentUser?.uid else { return } // Auto-generated Firebase user ID
        
        // Create time stamp
        let currentDateTime = Date()        // get the current date and time
        let formatter = DateFormatter()     // initialize the date formatter and set the style
        formatter.dateStyle = .medium       // "Oct 8, 2016"
        formatter.timeStyle = .medium       // "10:52:30 PM"
        let timeStamp = formatter.string(from: currentDateTime)  // "Oct 8, 2016, 10:52:30 PM"
        let dictTS = ["createdTime": timeStamp]
        var dict = dictionary  // cannot append to let dictionary thus created a temp dict1
        dict.append(other: dictTS)

        // Members/UID/[CollectionName]/CollectionID/[dictionary+Timestamp]
        let Ref = db.collection(FSCollectionName.Members.rawValue).document(UID)
                    .collection(collectionName.rawValue).document()
        Ref.setData(dict, merge: true)
        { (error) in
            if let error = error {
                print("Oh no! \(error.localizedDescription)")
            } else {
                print("Member data saved! \(Ref.documentID)")
            }
        }
    }
    
    func FSSaveMemberDocumentPathDict(documentPath: String, dictionary: Dictionary<String,Any>)
    {
        /*
         This function saves a subcollection tied to a member ID.
         Collections and documents must always follow the pattern
         of collection/document/collection/document.
         
         "Members/<UID>/Timers/<TimerID>/History/<HistoryID>/[dictionary+Timestamp]"
         */
        
        // Firestore Initialization
        let db = Firestore.firestore()
        
        // Adding FS timestamp to document
//        let ts = Timestamp().dateValue().description    // add Firebase Timestamp
//        let dictTS =    ["createdTime": ts]
        let dict = dictionary  // cannot append to let dictionary thus created a temp dict1
//        dict.append(other: dictTS)
        
        // example "Members/<UID>/Timers/<TimerID>/History/<HistoryID>/[dictionary+Timestamp]"
        let Ref = db.document(documentPath)
        Ref.setData(dict, merge: true)
        { (error) in
            if let error = error {
                print("Oh no! \(error.localizedDescription)")
            } else {
                print("Member data saved! \(Ref.documentID)")
            }
        }
    }

    func FSCollectionGIDDictSave(collectionName: FSCollectionName, dictionary: Dictionary<String,Any>)
    {
        // This function saves a collection tied to an auto-generated ID
        // [CollectionName]/<auto-generated ID>/[dictionary]

        let db = Firestore.firestore()

        var ref: DocumentReference? = nil
        ref = db.collection(collectionName.rawValue).addDocument(data:
            dictionary
        ) { (error) in
            if let error = error {
                print("Oh no! \(error.localizedDescription)")
            } else {
                print("Collection data saved! \(ref!.documentID)")
            }
        }
    }

}


extension Dictionary {
    mutating func append(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
