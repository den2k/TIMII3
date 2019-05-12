//
//  TimerCollectionViewController.swift
//  TIMII4
//
//  Created by Dennis Huang on 11/27/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/*

 TODO: 4.5.19 [DONE - 5.4.19] - Bug - Switching between settings and dashboard tab bar items causes the selected item to change which causes Switch timer alert failures.
       4.16.19 - previous global, active global values started correctly. now just need to highlight and correct cell.... between reloaddata..
 TODO: 12.24.18 - Feature - When NUMOFALLOWEDTIMERS is reached. Show $$$ Screen. (Ellie)
 TODO: 12.13.18 - Feature - Delete timers with press and hold gesture to show delete dialog.
 TODO: 3.23.19 [DONE - 4.4.19] - Bug 1 - switch to new timer when current timer is active.
 TODO: 11.28.18 [DONE - 12.1.18] - Make this into a collection view. Created a temporary visual timer dashboard with a collection view.
 TODO: 12.1.18 [DONE 12.1.18] - Cleanup unnecessary code from previous collection layout.
 TODO: 12.1.18 [DONE 12.1.18] - Remove use of templateCell
 TODO: 12.1.18 [DONE 12.4.18] - Retrieve existing Timers and display them in Timer Collection
 TODO: 12.5.18 [DONE 12.5.18] - Add a default image for each retrieved timer. We have 3 now.
 TODO: 12.1.18 [DONE 12.22.18] - Add 'Add Timer' functionality only to empty timer button
 TODO: 12.9.18 [DONE 12.13.18] - Limit timers to Max and fix reading more timers crashing
       1.6.19 [DONE 1.20.19] - Still crashing.
 TODO: 12.11.18 [DONE 12.13.18] - After adding new timers, refresh screen. Added observer to reload data.
 TODO: 12.13.18 [DONE 12.16.18] - Add Number of Timers Stats to Member document
 TODO: 12.17.18 [DONE 12.17.18] - Clear timer views upon new member login
 TODO: 12.13.18 [DONE 12.22.18] - Updated so newTimerScreen only shows with an empty Timer slot in didSelectItemAt. Limit the showing of New Timer Screen if user exceeds the number of timers allowed. Need to add stats into FS to do this.
        1.19.19 [DONE 1.20.19] - Delete timers from ActiveTimerVC Menu.
 TODO: 12.23.18 [DONE] - Highlighted background to show selected timer is messedup. Fix.
 TODO: 12.24.18 [DONE 12.24.18] - Show only 1 Add Timer at a time. (Ellie)
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
    private let add = UIImage(named: "menu-plus")
    private let images = [
        UIImage(named: "lifestyle-bike"),
        UIImage(named: "lifestyle-boating"),
        UIImage(named: "lifestyle-boxing"),
        UIImage(named: "lifestyle-cardio"),
        UIImage(named: "lifestyle-dumbbell"),
        UIImage(named: "lifestyle-jumprope"),
        UIImage(named: "lifestyle-running"),
        UIImage(named: "lifestyle-skiing"),
        UIImage(named: "lifestyle-soccer"),
        UIImage(named: "lifestyle-tennis")
    ]
    private var timerNames: [String] = [String](repeating: "Add Timer", count: NUMOFALLOWEDTIMERS)
    private var timerIDs: [String] = [String](repeating: "", count: NUMOFALLOWEDTIMERS)
    private var timerSlotIsEmpty: [Bool] = [Bool](repeating: true, count: NUMOFALLOWEDTIMERS)
    private var timerButtonText: String = ""        // The text shown on a collection button.
    private var isAddButton: Bool = true
    private var isTimerRunning: Bool = false
    private var numOfTimers: Int = 0
    private var activeTimerIndexPath: IndexPath? = nil   // 4.4.19 - works with shouldselectedItemAt
    private var activeTimerID: String = ""
    
//    private var localSavedActiveTimerID: String = ""
//    private var localSavedPreviousTimerID: String = ""
    
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
        
        /// When a timer is either created, updated or deleted - make sure to read the timer table again.
        NotificationCenter.default.addObserver(self, selector: #selector(readTimers), name: .didCreateNewTimer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(readTimers), name: .didUpdateExistingTimer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(readTimers), name: .didDeleteExistingTimer, object: nil)
        
        /// When a timer is running - switchTimerAlert must be called. To trigger this function requires knowing the isTimerRunning state.
        NotificationCenter.default.addObserver(self, selector: #selector(timerStartedRunning), name: .didStartTimer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(timerStoppedRunning), name: .didStopTimer, object: nil)
        
        readTimers()    // 4.30.19 - delete? - put into viewWillAppear instead?

        // Reading from file
//        guard let localTimerCollectionViewStats = TimerCollectionViewStatsFileHandler.shared.fetchTimerCollectionViewStats() else { return }
//        localSavedActiveTimerID = localTimerCollectionViewStats.savedActiveTimerID
//        localSavedPreviousTimerID = localTimerCollectionViewStats.savedPreviousTimerID

        // Reordering
//        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
//        timerCollectionView?.addGestureRecognizer(longPressGesture)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
    }
    
    /// This function allows the user to create a new timer
    @objc func newTimerScreen()
    {
        let newTimerScreen = NewTimerScreen()
        
        // Keeps the presenting "TimerCollectionViewController" VC in view beneath the presented "newTimerScreen" VC.
        newTimerScreen.modalPresentationStyle = .overFullScreen
        present(newTimerScreen, animated: true, completion: nil)
    }
    
    // TODO: 4.30.19 - Once the timer singleton/filemanager is created, reference the global value of isTimerRunning instead of the local class value of isTimerRunning.
    @objc func timerStartedRunning()    { isTimerRunning = true }
    @objc func timerStoppedRunning()    { isTimerRunning = false }
    
    
    /// This function shows a popup alert asking the user if they wish to switch to
    /// a new timer while the current timer is running.
    func switchTimerAlert(indexPath: IndexPath)
    {
        let alert = UIAlertController(title: "Switch Timers?", message: "Save current timer and switch to new timer?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            
            // On user input of "Yes" - initiate stop timer action by triggering a notification post for .stopTimerUser Input.
            print("-> Switch Timer -> Yes .stopTimerUserInput")
            let dict = [
                "timerID": self.activeTimerID,
                ] as [String : Any]
            NotificationCenter.default.post(name: .stopTimerUserInput, object: nil, userInfo: dict)
            
            // 5.4.19 - Must deselect first then select. Otherwise the ActiveTimerView would be hidden.
            self.timerCollectionView!.delegate?.collectionView!(self.timerCollectionView!, didDeselectItemAt: self.activeTimerIndexPath!)
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
        let timerIcon: UIImage
        if timerSlotIsEmpty[indexPath.row] == true {
            timerIcon = add!
            timerButtonText = "+"
            isAddButton = true
        } else {
            timerIcon = images[(indexPath.row) % 10]!
            timerButtonText = String(indexPath.row+1)
            isAddButton = false
        }
        
        // let identifier = (indexPath.row % 2 == 0) ? "templateCell" : "standaloneCell"
        let node = collectionView.dequeueReusableCellNode(withIdentifier: identifier, for: indexPath)
        
        node.setState([
            "row": indexPath.row,
            "timerName": timerNames[indexPath.row],             // User generated timer name
            "timerIcon": timerIcon,                             // Timer icon image
            "timerIsEmpty": timerSlotIsEmpty[indexPath.row],
            "timerButtonText":  timerButtonText,                // 1 to n button count displayed on timer icon
            "isAddButton": isAddButton,
            ])
        
        return node.view as! UICollectionViewCell
    }
    
    /// This function preprocesses the user input when a cell is selected without handling the selection action itself.
    /// https://www.raywenderlich.com/9477-uicollectionview-tutorial-reusable-views-selection-and-reordering
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
    {
        print("-> TimerCollectionViewController/shouldSelectItemAt:", indexPath.row)    // can delete
        if isTimerRunning {
            switchTimerAlert(indexPath: indexPath)
            return false
        } else {
            return true
        }
    }
    
    /// This function handles the selection of a Timer within the Collection View.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        print("-> TimerCollectionViewController/didSelectItemAt:", indexPath.row)    // can delete
        let cell = collectionView.cellForItem(at: indexPath)

        // 5.4.19 This works in combination with shouldSelectedItemAt/switchTimerAlert to hold the running timer indexPath and timerID values.
        // 5.4.19 Needs this extra didDeselectItemAt call because background not resetting after a switch timer during run.
        if (activeTimerIndexPath != nil) { self.timerCollectionView!.delegate?.collectionView!(self.timerCollectionView!, didDeselectItemAt: self.activeTimerIndexPath!) }
        activeTimerIndexPath = indexPath
        activeTimerID = timerIDs[indexPath.row]
        
        // An empty timer slot has been selected so show the newTimerScreen so a new timer can be created.
        if timerSlotIsEmpty[indexPath.row] == true {
            cell?.backgroundColor = UIColor.transparent     // Unhighlight selected cell when Add Timer is selected.
            newTimerScreen()
        } else {
            cell?.backgroundColor = UIColor.white
            let dict = [
                "index": indexPath.row,
                "timerID": timerIDs[indexPath.row],
                ] as [String : Any]
            NotificationCenter.default.post(name: .didSelectNewActiveTimer, object: nil, userInfo: dict)

            // Save to disk - may not need
//            localSavedActiveTimerID = timerIDs[indexPath.row]
//            let g = TimerCollectionViewStats(
//                savedActiveTimerID: localSavedActiveTimerID,
//                savedPreviousTimerID: localSavedPreviousTimerID)
//            TimerCollectionViewStatsFileHandler.shared.save(g)
//            print("TimerCollectionViewController/didSelectItemAt:",g)
        }
    }
    
    /// This function handles the deselection of a Timer within the Collection View.
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
        print("-> TimerCollectionViewController/didDeselectItemAt:", indexPath.row)    // can delete
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.transparent
        NotificationCenter.default.post(name: .didDeselectActiveTimer, object: nil)

        /// Save to disk
//        activeTimerIndexPath = indexPath
//        localSavedPreviousTimerID = timerIDs[indexPath.row]
//        print("TimerCollectionViewController/didDeselectItemAt/localSavedPreviousTimerID: ", localSavedPreviousTimerID) // can delete

        // may not need saving of active/previous timerID
//        let g = TimerCollectionViewStats(
//            savedActiveTimerID: localSavedActiveTimerID,
//            savedPreviousTimerID: localSavedPreviousTimerID)
//        TimerCollectionViewStatsFileHandler.shared.save(g)
//        print("-> TimerCollectionViewController/didDeselectItemAt:",g)
    }
    
    // Reorder Collection View Items
        // https://developer.apple.com/documentation/uikit/uicollectionview
        // https://hackernoon.com/swift-reorder-cells-in-uicollectionview-using-drag-drop-ff7eb5131052
    // Drag and Drop - https://developer.apple.com/videos/play/wwdc2017/223/
//    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool { return true }
//    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        print("Starting Index: \(sourceIndexPath.item)")
//        print("Ending Index: \(destinationIndexPath.item)")
//
//        let item = timerIDs.remove(at: sourceIndexPath.item)
//        timerIDs.insert(item, at: destinationIndexPath.item)
//    }
//
//    // default: true - https://developer.apple.com/documentation/uikit/uicollectionviewcontroller/1623979-installsstandardgestureforintera
//    var installsStandardGestureForInteractiveMovement: Bool = true
//
//    fileprivate var longPressGesture: UILongPressGestureRecognizer!
//
//    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
//        switch(gesture.state) {
//
//        case .began:
//            guard let selectedIndexPath = timerCollectionView?.indexPathForItem(at: gesture.location(in: timerCollectionView)) else {
//                break
//            }
//            timerCollectionView?.beginInteractiveMovementForItem(at: selectedIndexPath)
//        case .changed:
//            timerCollectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
//        case .ended:
//            timerCollectionView?.endInteractiveMovement()
//        default:
//            timerCollectionView?.cancelInteractiveMovement()
//        }
//    }
    
    

}





extension TimerCollectionViewController
{

// MARK: ---------- FIRESTORE FUNCTIONS ----------

    /// This function reads a specific set of fields from a member's list of created Timers directly from Firestore.
    @objc func readTimers()
    {
        print("--> TimerCollectionViewController/readTimers()")   // can delete
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
                        
                        self.timerNames[index] = timerDoc["name"] as? String ?? ""
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
                        self.timerNames[index] = "Add Timer"
                        self.timerIDs[index] = ""
                        self.timerSlotIsEmpty[index] = true
                    }
                }
                
                DispatchQueue.main.async { self.timerCollectionView?.reloadData() }
                
                /// 5.3.19 - Resets the any selections made
                self.timerCollectionView?.indexPathsForSelectedItems?
                    .forEach {
                        self.timerCollectionView?.deselectItem(at: $0, animated: false)
                        self.timerCollectionView?.backgroundColor = UIColor.transparent
                }
            }
        }
    }
    
    
}

