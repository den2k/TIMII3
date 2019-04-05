//
//  TimerCollectionViewController.swift
//  TIMII4
//
//  Created by Dennis Huang on 11/27/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/*

 TODO: 3.23.19 [DONE - 4.4.19] - Bug 1 - switch to new timer when current timer is active.
 TODO: 11.28.18 [DONE - 12.1.18] - Make this into a collection view. Created a temporary visual timer dashboard with a collection view.
 TODO: 12.1.18 [DONE 12.1.18] - Cleanup unnecessary code from previous collection layout.
 TODO: 12.1.18 [DONE 12.1.18] - Remove use of templateCell
 TODO: 12.1.18 [DONE 12.4.18] - Retrieve existing Timers and display them in Timer Collection
 TODO: 12.5.18 [DONE 12.5.18] - Add a default image for each retrieved timer. We have 3 now.
 TODO: 12.1.18 [DONE 12.22.18] - Add 'Add Timer' functionality only to empty timer button
 TODO: 12.9.18 [DONE 12.13.18] - Limit timers to Max and fix reading more timers crashing
       1.6.19 [DONE 1`.20.19] - Still crashing.
 TODO: 12.11.18 [DONE 12.13.18] - After adding new timers, refresh screen. Added observer to reload data.
 TODO: 12.13.18 [DONE 12.16.18] - Add Number of Timers Stats to Member document
 TODO: 12.17.18 [DONE 12.17.18] - Clear timer views upon new member login
 TODO: 12.13.18 [DONE 12.22.18] - Updated so newTimerScreen only shows with an empty Timer slot in didSelectItemAt. Limit the showing of New Timer Screen if user exceeds the number of timers allowed. Need to add stats into FS to do this.
 TODO: 12.13.18 - Delete timers with press and hold gesture to show delete dialog.
        1.19.19 [DONE 1.20.19] - Delete timers from ActiveTimerVC Menu.
 TODO: 12.23.18 [DONE] - Highlighted background to show selected timer is messedup. Fix.
 TODO: 12.24.18 [DONE 12.24.18] - Show only 1 Add Timer at a time. (Ellie)
 TODO: 12.24.18 - When NUMOFALLOWEDTIMERS is reached. Show $$$ Screen. (Ellie)
 TODO: 1.13.19 [DONE 1.20.19] - Update an existing timer
 
 NOTE:
 UICollectionView UIGestureRecognizer on Long Press not working with Layout.... Issued a ticket on 12/15. No response yet.
 
 */

import Layout
import UIKit
import Firebase

private let NUMOFALLOWEDTIMERS = Main().MAXNUMOFTIMERS

class TimerCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, Ownable
{

    
/* MARK: ---------- VIEW CONTROLLER PROPERTIES ----------
     
     Place common view controller properties here.
     
 */
    private let add = UIImage(named: "Add")
    private let images = [
        UIImage(named: "One"),
        UIImage(named: "Two"),
        UIImage(named: "Three"),
        UIImage(named: "Four"),
        UIImage(named: "Five"),
        UIImage(named: "Six"),
        UIImage(named: "Seven"),
        UIImage(named: "Eight"),
        UIImage(named: "Nine"),
        UIImage(named: "Ten")
    ]
    private var timerTitles: [String] = [String](repeating: "Add Timer", count: NUMOFALLOWEDTIMERS)
    private var timerIDs: [String] = [String](repeating: "", count: NUMOFALLOWEDTIMERS)
    private var timerSlotIsEmpty: [Bool] = [Bool](repeating: true, count: NUMOFALLOWEDTIMERS)
    private var timerButtonText: String = ""        // The text shown on a collection button.
    private var isAddButton: Bool = true
    private var isTimerRunning: Bool = false
    private var numOfTimers: Int = 0
    private var previousSelectedTimerID: String = ""    // 4.4.19 - Works with shouldSelectItemAt
    private var previousSelectedTimerIDIndexpath: IndexPath? = nil   // 4.4.19 - works with shouldselectedItemAt

    // 3.30.19 - This property is not necessary if shouldSelectItemAt is not used.
    // A way to update the collection view when this property changes.
    var selectedTimerIndexPath: IndexPath? {
        didSet {
            var indexPaths: [IndexPath] = []
            if let selectedTimerIndexPath = selectedTimerIndexPath {
                indexPaths.append(selectedTimerIndexPath)
                print(indexPaths)
            }
        }
    }
    
    
    @IBOutlet var timerCollectionView: UICollectionView?
    {
        didSet {
            timerCollectionView?.registerLayout(
                named: "TimerCollectionCell.xml",
                forCellReuseIdentifier: "timerCollectionCell"
            )
        }
    }
    
    

/* MARK: ---------- VIEW CONTROLLER FUNCTIONS ----------
 
     Place generic view controller functions here (ie: viewDidLoad).
 
 */
    override func viewDidLoad()
    {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(readTimers), name: .didCreateNewTimer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(readTimers), name: .didUpdateExistingTimer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(readTimers), name: .didDeleteExistingTimer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(timerIsRunning), name: .didStartTimer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(timerIsNotRunning), name: .didStopTimer, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        // Reset timer when it reappears.
        readTimers()
    }
    
    @objc func newTimerScreen()
    {
        let newTimerScreen = NewTimerScreen()
        
        // Keeps the presenting "TimerCollectionViewController" VC in view beneath the presented "newTimerScreen" VC.
        newTimerScreen.modalPresentationStyle = .overFullScreen
        present(newTimerScreen, animated: true, completion: nil)
    }
    
    @objc func timerIsRunning()     { isTimerRunning = true }
    @objc func timerIsNotRunning()
    {
        isTimerRunning = false
        self.timerCollectionView?.reloadData()
    }
    
    
    /// This function shows a popup alert asking the user if they wish to switch to
    /// a new timer while the current timer is running.
    func showConfirmationPopUp(indexPath: IndexPath)
    {
        let alert = UIAlertController(title: "Switch Timers?", message: "Save current timer and switch to new timer?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            
            // Stop and save running timer.
            print("-> .stopTimer")
            let dict = [
                "timerID": self.previousSelectedTimerID,
                ] as [String : Any]
            NotificationCenter.default.post(name: .stopTimer, object: nil, userInfo: dict)

            // Switch to selected new timer
            self.timerCollectionView!.delegate?.collectionView!(self.timerCollectionView!, didDeselectItemAt: self.previousSelectedTimerIDIndexpath!)
            self.timerCollectionView!.delegate?.collectionView!(self.timerCollectionView!, didSelectItemAt: indexPath)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in })
        self.present(alert, animated: true, completion: nil)
    }
    
/* MARK: ---------- COLLECTIONVIEW FUNCTIONS ----------
 
     Place CollectionView functions here.
     
 */

    /// This function sets the number of Timers to be displayed with the total number of created Timers by the user plus one 'Add Timer' cell
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int
    {
        if numOfTimers == NUMOFALLOWEDTIMERS { return NUMOFALLOWEDTIMERS }
        else { return numOfTimers + 1 }
        
    }
    
    /// This function is responsible for creating, configuring, and returning a Timer in the Collection View.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let identifier: String = "timerCollectionCell"
        
        // Sets default timer image when a timer is loaded
        let image: UIImage
        if timerSlotIsEmpty[indexPath.row] == true {
            image = add!
            timerButtonText = "+"
            isAddButton = true
        } else {
            image = images[(indexPath.row) % 10]!
            timerButtonText = String(indexPath.row+1)
            isAddButton = false
        }
        
//        let identifier = (indexPath.row % 2 == 0) ? "templateCell" : "standaloneCell"
        let node = collectionView.dequeueReusableCellNode(withIdentifier: identifier, for: indexPath)
        
        node.setState([
            "row": indexPath.row,
            "title": timerTitles[indexPath.row],
            "image": image,
            "timerIsEmpty": timerSlotIsEmpty[indexPath.row],
            "timerButtonText":  timerButtonText,
            "isAddButton": isAddButton,
            ])
        
        return node.view as! UICollectionViewCell
    }
    
    /// This function preprocesses the user input when a cell is selected without handling the selection action itself.
    /// https://www.raywenderlich.com/9477-uicollectionview-tutorial-reusable-views-selection-and-reordering
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
    {
        print("-> TimerCollectionViewController/shouldSelectItemAt")    // can delete
        if isTimerRunning {
            showConfirmationPopUp(indexPath: indexPath)
            return false
        } else {
            return true
        }
    }
    
    /// This function handles the selection of a Timer within the Collection View.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let cell : UICollectionViewCell = collectionView.cellForItem(at: indexPath as IndexPath)!
        
        // 4.4.19 - used with shouldSelectItemAt
        previousSelectedTimerIDIndexpath = indexPath
        previousSelectedTimerID = timerIDs[indexPath.row]
        
        if timerSlotIsEmpty[indexPath.row] == true {
            // An empty timer slot has been selected so show the newTimerScreen so a new timer can be created
            cell.backgroundColor = UIColor.transparent
            newTimerScreen()
        } else {
            print("-post didSelectNewActiveTimer-") // delete
            cell.backgroundColor = UIColor.white
            let dict = [
                "index": indexPath.row,
                "timerID": timerIDs[indexPath.row],
                ] as [String : Any]
            NotificationCenter.default.post(name: .didSelectNewActiveTimer, object: nil, userInfo: dict)
        }
        print("Selected: \(indexPath.row)")     //delete
    }
    
    /// This function handles the deselection of a Timer within the Collection View.
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
        let cell : UICollectionViewCell = collectionView.cellForItem(at: indexPath as IndexPath)!
        
        cell.backgroundColor = UIColor.transparent
        previousSelectedTimerID = timerIDs[indexPath.row]
        previousSelectedTimerIDIndexpath = indexPath
        print("previousSelectedTimerID: ", previousSelectedTimerID) // can delete
        
        // Sends a notification that the active timer is no longer being selected
        NotificationCenter.default.post(name: .didDeselectActiveTimer, object: nil)
    }
    
}





extension TimerCollectionViewController
{

// MARK: ---------- FIRESTORE FUNCTIONS ----------

    /// This function reads a specific set of fields from a member's list of created Timers directly from Firestore.
    @objc func readTimers()
    {
//        var timerCount: Int = 0
        
        let db = Firestore.firestore()
        
        db.collection("Members").document(memberID).collection("Timers").getDocuments() { (querySnapshot, error) in
            if let err = error {
                print("Error getting document: \(err)")
            } else {
                for (index, document) in querySnapshot!.documents.enumerated()
                {
                    print("\(index):--->>>\(document.documentID) => \(document.data())")
                    let timerDoc = document.data()
                    if index < NUMOFALLOWEDTIMERS {
                        
                        self.timerTitles[index] = timerDoc["name"] as? String ?? ""
                        self.timerIDs[index] = document.documentID
                        self.timerSlotIsEmpty[index] = false
                        self.numOfTimers = index + 1    // For looping through timerCount
                        print("numOfTimers: \(self.numOfTimers) \(self.timerIDs[index])")   //delete
                    
                    } else {
                
                        print("Too many timers!")
                    
                    }
                }
                
                // Loop through blank timers
                // 12.22.18 - Do I need to do this if / for loop????
                if self.numOfTimers < NUMOFALLOWEDTIMERS
                {
                    for index in self.numOfTimers...NUMOFALLOWEDTIMERS-1
                    {
                        print(index)
                        self.timerTitles[index] = "Add Timer"
                        self.timerIDs[index] = ""
                        self.timerSlotIsEmpty[index] = true
                    }
                }
                    
                DispatchQueue.main.async { self.timerCollectionView?.reloadData() }
                print(self.timerTitles)  // delete
            }
        }
    }
    
    
}

