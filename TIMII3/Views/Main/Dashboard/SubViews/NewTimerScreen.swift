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
 TODO: 12.24.18 [DONE 12.24.18] - Add empty timer check.
 
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
        guard let name = nameTextField?.text, !name.isEmpty, let description = descriptionTextField?.text, !description.isEmpty else
        {
            self.errorLabel?.text = "Please enter timer information"
            self.updateView()
            return
        }
            
        // Save new timer
        Timii().FSSave(name: name, description: description)
        
        // Update a member's Timers stats like numOfTimer count.
        Member().FSUpdateTimersStats()

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
