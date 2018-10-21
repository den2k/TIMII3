//
//  CreateAccountScreen.swift
//  TIMII3
//
//  Created by Dennis Huang on 7/28/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

/* --- TODO Section ---
 
 TODO: 8.5.18 [DONE] - need to dismiss to Main screen and not just LoginScreen : https://stackoverflow.com/questions/3224328/how-to-dismiss-2-modal-view-controllers-in-succession/44583711#44583711
 TODO: 8.6.18 [DONE 8.7.18] - Added user info to Firebase - uid, email, fullName, password
 TODO: 8.7.18: Refactor keyboard specific items to separate file
 TODO: 8.7.18 [DONE 8.7.18] - Refactor UUID in createUser as its not best practice and long -> Using Firebase currentUser ID
 TODO: 8.7.18 [DONE 8.7.18] - Add 1 to Firebase Member Countable once member is added successfully
 TODO: 8.7.18: Add Verify Password matches error handler
 TODO: 8.16.18: Refactor FB code and move Auth portion to new AuthenticationSystem and use Firestore in DatabaseSystem to store Members info.
 TODO: 10.10.18 [DONE 10.10.18] - Migrated code from TIMII to TIMII3
 TODO: 10.21.18 [DONE 10.21.18] - Use Firestoreable FSSave to save Member information within the Member Collection
 TODO: 10.10.18 - Redo Counting in FS. Need to implement Firestoreable / addUserComponentCountableDict so it saves Firestore and not Firebase. This is so counting of added Members works again.
 
 */

import UIKit
import Layout
import Firebase

class CreateAccountScreen: UIViewController, LayoutLoading
{
    var isKeyboardVisible = false
    
    // Create Account Properties
    @IBOutlet var emailTextField : UITextField?
    @IBOutlet var passwordTextField : UITextField?
    @IBOutlet var errorLabel : UILabel?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.loadLayout(
            named: "CreateAccountScreen.xml",
            state:[
                "isKeyboardVisible": isKeyboardVisible,
                "error": errorLabel?.text as Any
            ]
        )
    }
    
    // MARK: ---------- CREATE ACCOUNT HANDLER / MEMBER CREATION ----------
    // This section handles the registration request and adding new member to Firebase
    
    @objc func handleCreateAccount()
    {
        guard let email = emailTextField?.text, let password = passwordTextField?.text else
        {
            print("Form is not valid. Unable to create account.")
            return
        }
        
        // This creates a new user using the Firestore Auth procedures
        Auth.auth().createUser(withEmail: email, password: password, completion:
            {(user, error) in
                if error != nil
                {
                    print(error ?? "Error creating user.")
                    self.errorLabel?.text = error?.localizedDescription
                    self.updateView()
                    return
                }
                
                /*
                 10.12.18 - Given authorized members are already contained in the Auth section of Firestore
                 why do I need to save this info?  I shouldn't create my own member Collection that stores this
                 information. There is probably a bunch of security/hacking related issues that are involved
                 in storing user data so I don't need this? ==>> My decision is NOT to store user authorization
                 data like email/passwords inside Member.
                 
                 10.21.18 - Will save email information but not passwords. In case I need to migrate users from FS.
                 May also need to save passwords if that is the case....For now just save email.
                 */
                let newMember = Member(email: email)
                newMember.FSSave()
                print(newMember)
                
                // Dismiss both present CreateAccount VC and Login VC to arrive at Main
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        })
    }
    
    // dismiss to LoginScreen
    @objc func loginScreen() { dismiss(animated: true, completion: nil) }
    
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

