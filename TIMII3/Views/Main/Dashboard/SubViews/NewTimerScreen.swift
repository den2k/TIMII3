//
//  NewTimerScreen.swift
//  TIMII3
//
//  Created by Dennis Huang on 12/8/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/* --- TODO Section ---
 
 TODO: 12.8.18 [DONE 12.12.18] - Create a simple popup for creating a new timer.
 TODO: 12.13.18 [DONE 12.16.18] - add timer stats: numOfTimers (Member), maxNumOfTimers (Member)
 
 */

import UIKit
import Layout

class NewTimerScreen: UIViewController, LayoutLoading
{
    var isKeyboardVisible = false
    
    // Create Account Properties
    @IBOutlet var nameTextField : UITextField?
    @IBOutlet var descriptionTextField : UITextField?
    @IBOutlet var errorLabel : UILabel?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.loadLayout(
            named: "NewTimerScreen.xml",
            state:[
                "isKeyboardVisible": isKeyboardVisible,
                "error": errorLabel?.text as Any
            ]
        )
    }

    
    // MARK: ---------- CREATE TIMER HANDLER ----------
    // This section handles the creation of a new timer and adds this to Firestore
    
    @objc func handleNewTimer()
    {
        guard let name = nameTextField?.text, let description = descriptionTextField?.text else
        {
            print("Form is not valid. Unable to create timer.")
            return
        }
        
        let dict = [
            "name": name,
            "description": description,
        ]
        
        // This creates a new timer
        FS().FSSaveMemberCollectionDict(collectionName: FSCollectionName.Timers, dictionary: dict)
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: .didCreateNewTimer, object: nil)
        })
        
        // Saves Timer stats that need updating
        updateTimerStats()

        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: .didCreateNewTimer, object: nil)
        })
        
    }
    
    @objc func cancel()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func updateView()
    {
        // Calling setState() on a LayoutNode after it has been created will
        // trigger an update. The update causes all expressions in that node
        // and its children to be re-evaluated.
        self.layoutNode?.setState([
            "isKeyboardVisible": isKeyboardVisible,
            "error": errorLabel?.text as Any
            ])
    }
    
    // MARK: ---------- KEYBOARD FUNCTIONS ----------
    // This section controls keyboard Show or Hide functions
    
    @objc func keyboardWillShow(notification: Notification)
    {
        isKeyboardVisible = true
        updateView()
    }
    
    @objc func keyboardWillHide(notification: Notification)
    {
        isKeyboardVisible = false
        updateView()
    }
    
    // Dismiss the keyboard after RETURN press
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return false
    }
}

extension Notification.Name {
    static let didCreateNewTimer = Notification.Name("didCreateNewTimer")
}



import Firebase

extension NewTimerScreen: Ownable
{
    @objc func updateTimerStats()
    {
        let db = Firestore.firestore()
        let memberRef: DocumentReference = db.collection(FSCollectionName.Members.rawValue).document(memberID)
        
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
