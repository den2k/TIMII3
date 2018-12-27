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
 TODO: 12.16.18 [DONE 12.16.19] - Added default numOfTimers, MaxNumOfTimers values.
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
        let dict: [String:Any] = [
            "email":            self.email,
            "fullName":         self.fullName,
            "userName":         self.userName,
            "authMethod":       authMethod.rawValue,
            "maxNumOfTimers":   Main().MAXNUMOFTIMERS,
            "numOfTimers":      0,
            ]
        
        FS().FSSaveMember(userName: self.userName, dictionary: dict)
     
        // Create First Default timer for a new Member
        let name = "First Timer"
        let desc = "Change this timer to one that suits you."
        let t = Timii(name: name, description: desc)
        t.FSSave(name: name, description: desc)
        
    }
    
}

extension Member
{
    /*
     This function updates statistics related to all timers for a Member.
     This function does not update individual timer statistics.
     */
    @objc func FSUpdateTimersStats()
    {
        print("FSUpdateTimersStats - Updated Timers statistics.")
        
        let db = Firestore.firestore()
        let memberRef: DocumentReference = db.collection("Members").document(memberID)
        
        // https://firebase.google.com/docs/firestore/solutions/aggregation
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            
            let memberDocument: DocumentSnapshot
            do {
                try memberDocument = transaction.getDocument(memberRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let numOfTimers = memberDocument.data()?["numOfTimers"] as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve member data from snapshot \(memberDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            var newNumOfTimers: Int = 0
            
            if numOfTimers < Main().MAXNUMOFTIMERS {
                newNumOfTimers = numOfTimers + 1
            } else {
                print("Too many timers. Cannot add anymore.")
                newNumOfTimers = numOfTimers
            }
            
            // Commit to Firestore - Merge updates existing documents, but doesn't create..
            transaction.updateData(["numOfTimers": newNumOfTimers], forDocument: memberRef)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error.localizedDescription)")
            } else {
                print("Member data tranasaction updated! \(memberRef.documentID)")
            }
        }
        
    }

}
