//
//  NewTimerScreen.swift
//  TIMII3
//
//  Created by Dennis Huang on 12/8/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/* --- TODO Section ---
 
 TODO: 12.8.18 - Create a simple popup for creating a new timer.
 
 */

import UIKit
import Layout
import Firebase

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
        self.dismiss(animated: true, completion: nil)
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

