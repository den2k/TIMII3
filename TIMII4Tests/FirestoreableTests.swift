//
//  FirestoreableTests.swift
//  TIMII4Tests
//
//  Created by Dennis Huang on 10/10/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

/*
 10.10.18 - Firebase/Firestore testing is not easy/possible? without
 using Firestore Test Lab.  Read here
 https://stackoverflow.com/questions/42588087/testing-firebase-classes-in-swift-xctest
 https://firebase.google.com/docs/test-lab/ios/firebase-console
 */

import XCTest
import Firebase

class FirestoreableTests: XCTestCase
{

    func simpleTest()
    {
        // Add a new document with a generated ID
        // 10.10.18 - This comes from Firebase directly and has been used
        // in a VC to check if it works. It works.
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: [
            "first": "Ada",
            "last": "Lovelace",
            "born": 1815
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
}
