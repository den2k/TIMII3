//
//  ChangeTimerScreen.swift
//  TIMII4
//
//  Created by Dennis Huang on 1/19/19.
//  Copyright © 2019 Autonomii. All rights reserved.
//

// MARK: ----- TODOs -----
// TODO: 1.20.19 - Create Cloud Function to DELETE Logs collection for a deleted Timer.



import UIKit
import Firebase
import Layout

class ChangeTimerScreen: UIViewController, LayoutLoading
{
    /** Initialization Variables */
    
    /// Used to hold timerID during initialization
    var timerID: String = ""
    
    /// Used to hold timer object within the
    var timer = Timii(name: " ", description: " ")
    var isKeyboardVisible = false
    
    /// Create Account Properties
    @IBOutlet var changeNameTextField : UITextField?
    @IBOutlet var changeDescriptionTextField : UITextField?
    @IBOutlet var errorLabel : UILabel?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        /// Triggered by a Menu Press
        NotificationCenter.default.addObserver(self, selector: #selector(FSReadTimerInfo), name: .onDidPressActiveTimerMenuButton, object: nil)
        
        /// Dismiss Keyboard on Tap
        self.didTapHideKeyboard()
        
        self.loadLayout(
            named: "ChangeTimerScreen.xml",
            state:[
                "name"              : changeNameTextField?.text as Any,
                "description"       : changeDescriptionTextField?.text as Any,
                "isKeyboardVisible" : isKeyboardVisible,
                "error"             : errorLabel?.text as Any
            ]
        )
    }
    
    
    // MARK: ---------- UPDATE TIMER HANDLER ----------
    // This section handles the creation of a new timer and adds this to Firestore
    
    @objc func getTimerID(_ notification : Notification)
    {
        // --- Read Timer Info ---
        self.timerID = notification.userInfo?["timerID"] as? String ?? ""
        print("timerID: \(timerID)")
//        FSReadTimerInfo()
    }
    
    @objc func onDidPressUpdateTimer()
    {
        print("->onDidPressUpdateTimer")
        
        
        // --- Save Timer Info ---
        guard let name = changeNameTextField?.text, !name.isEmpty, let description = changeDescriptionTextField?.text else
        {
            self.errorLabel?.text = "Please enter timer information"
            self.updateView()
            return
        }

        // Save updated timer
        FSUpdateTimerInfo(name: name, desc: description)
        
        
        self.dismiss(animated: true, completion: {
            let dict = [
                "timerID": self.timerID,
                ] as [String : Any]
            NotificationCenter.default.post(name: .didUpdateExistingTimer, object: nil, userInfo: dict)
        })

    }
    
    @objc func onDidPressDeleteTimer()
    {
        print("->onDidPressDeleteTimer")
        
        FSDeleteTimer()
        
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: .didDeleteExistingTimer, object: nil)
        })
    }
    
    @objc func onDidPressCancelButton()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func updateView()
    {
        // Calling setState() on a LayoutNode after it has been created will
        // trigger an update. The update causes all expressions in that node
        // and its children to be re-evaluated.
        self.layoutNode?.setState([
//            "name"                  : changeNameTextField?.text as Any,
//            "description"           : changeDescriptionTextField?.text as Any,
            "isKeyboardVisible"     : isKeyboardVisible,
            "error"                 : errorLabel?.text as Any
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


// MARK: ---------- FIRESTORE FUNCTIONS ----------

extension ChangeTimerScreen: Ownable
{
    // This func is on the receiving end of a Notification to READ a Timer document.
    // This function only reads the 'name' and 'description' fields.
    @objc private func FSReadTimerInfo(_ notification: Notification)
    {
        // --- Read Timer Info ---
        self.timerID = notification.userInfo?["timerID"] as? String ?? ""
        print("-> ChangeTimerScreen:FSReadTimerInfo( \(self.timerID) )")   // delete
        
        let db = Firestore.firestore()
        
        db.collection("Members").document(memberID)
          .collection("Timers").document(self.timerID).getDocument()
        { (document, error) in
            if let err = error {
                print("Error getting document: \(err)")
            } else {
                let timerDoc                = document?.data()
                let timerName               = timerDoc!["name"] as? String ?? ""
                let timerDescription        = timerDoc!["description"] as? String ?? ""

                print("--> \(timerName) - \(timerDescription)")
                
                self.layoutNode?.setState([
                    "name"              : timerName,
                    "description"       : timerDescription,
                ])
            }
        }
    }
    
    // This function updates the fields 'name' and 'description' for a Timer document.
    @objc private func FSUpdateTimerInfo(name: String, desc: String)
    {
        print("-> ChangeTimerScreen:FSUpdateTimerInfo")
        
        let db = Firestore.firestore()
        
        let Ref = db.collection("Members").document(memberID)
                    .collection("Timers").document(self.timerID)
       
        Ref.updateData([
            "name"          : name,
            "description"   : desc,
        ]) { (error) in
            if let error = error {
                print("Oh no! \(error.localizedDescription)")
            } else {
                print("Timer data updated! \(Ref.documentID)")
            }
        }
        
    }

    @objc private func FSDeleteTimer()
    {
        // --- Delete Timer Document ---
        print("-> ChangeTimerScreen:FSDeleteTimer")   // delete
        
        let db = Firestore.firestore()
        
        
        // Delete all Logs Associated with Timer being Deleted FIRST
        // https://firebase.google.com/docs/firestore/solutions/delete-collections
        print("To Delete the Logs collection requires using Cloud Functions")
        
        
        // --- Delete Timer Document ---
        db.collection("Members").document(memberID)
          .collection("Timers").document(self.timerID).delete()
            { (error) in
                if let err = error {
                    print("Error deleting document: \(err)")
                } else {
                    print("Timer successfully deleted!")
                }
            }
        
        
        // --- Reduce number of timers by 1 ---
        let memberRef = db.collection("Members").document(memberID)
        
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
            
            if numOfTimers > 0 {
                newNumOfTimers = numOfTimers - 1
            } else {
                print("Cannot substract anymore.")
                newNumOfTimers = 0
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
