//
//  TimerCollectionViewController.swift
//  TIMII4
//
//  Created by Dennis Huang on 11/27/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/**

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
 TODO: 3.23.19 - Bug 1 - switch to new timer when current timer is active.
 
 NOTE:
 UICollectionView UIGestureRecognizer on Long Press not working with Layout.... Issued a ticket on 12/15. No response yet.
 
 */

import Layout
import UIKit
import Firebase

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

private let NUMOFALLOWEDTIMERS = Main().MAXNUMOFTIMERS

class TimerCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, Ownable
{
//    var db: Firestore!
    
    var timerTitles: [String] = [String](repeating: "Add Timer", count: NUMOFALLOWEDTIMERS)
    var timerIDs: [String] = [String](repeating: "", count: NUMOFALLOWEDTIMERS)
    var timerSlotIsEmpty: [Bool] = [Bool](repeating: true, count: NUMOFALLOWEDTIMERS)
    var timerButtonText: String = ""        // The text shown on a collection button.
    var isAddButton: Bool = true
    var isTimerRunning: Bool = false
//    var activeTimers: [Int] = []
    
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
    
    // Used to store
    var numOfTimers: Int = 0

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(readTimers), name: .didCreateNewTimer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(readTimers), name: .didUpdateExistingTimer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(readTimers), name: .didDeleteExistingTimer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(timerIsRunning), name: .didStartTimer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(timerIsNotRunning), name: .didStopTimer, object: nil)
        
        // Add Long Press Gesture to trigger UPDATE / DELETE function
//        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onDidLongPressTimer))
//        lpgr.minimumPressDuration = 0.5
//        lpgr.delegate = self
//        lpgr.delaysTouchesBegan = true
//        self.timerCollectionView?.addGestureRecognizer(lpgr)
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        // Reset timer when it reappears.
        readTimers()
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
    
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int
    {
        // The Collection displays the total number of created Timers plus one 'Add Timer' cell
        if numOfTimers == NUMOFALLOWEDTIMERS { return NUMOFALLOWEDTIMERS }
        else { return numOfTimers + 1 }
        
    }
    
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
//            "selectedTimerIndexPath": selectedTimerIndexPath,
            ])
        
        return node.view as! UICollectionViewCell
    }
    
  
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let cell : UICollectionViewCell = collectionView.cellForItem(at: indexPath as IndexPath)!
        
        if timerSlotIsEmpty[indexPath.row] == true {
            
            // An empty timer slot has been selected so show the newTimerScreen so a new timer can be created
            cell.backgroundColor = UIColor.green
            newTimerScreen()
            
        } else {
            
            // 3.26.19 - Alert doesn't work yet.
//            if isTimerRunning {
//                let alert = UIAlertController(title: "Switch Timers?", message: "", preferredStyle: UIAlertController.Style.alert)
//                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler:
//                { (alert:UIAlertAction) -> Void in
////                    self.saveCurrentTimer(timerID: self.timerIDs[indexPath.row])
//
//                    Timii().FSSaveSelectedTimerLog(timerID: self.timerIDs[indexPath.row])
//
//                }))
//                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler:
//                { (alert:UIAlertAction) -> Void in
//
//                }))
//                self.present(alert, animated: true, completion: nil)
//            } else {
//                // A Member timer has been selected so show this timer in the ActiveTimer View Controller
//                cell.backgroundColor = UIColor.white
//                let dict = [
//                    "index": indexPath.row,
//                    "timerID": timerIDs[indexPath.row],
//                    ] as [String : Any]
//                NotificationCenter.default.post(name: .didSelectNewActiveTimer, object: nil, userInfo: dict)
//                print("-post didSelectNewActiveTimer-") // delete
//            }

            cell.backgroundColor = UIColor.white
            let dict = [
                "index": indexPath.row,
                "timerID": timerIDs[indexPath.row],
                ] as [String : Any]
            NotificationCenter.default.post(name: .didSelectNewActiveTimer, object: nil, userInfo: dict)
            print("-post didSelectNewActiveTimer-") // delete

        }
        
        print("Selected: \(indexPath.row)")     //delete
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
        let cell : UICollectionViewCell = collectionView.cellForItem(at: indexPath as IndexPath)!
        
        cell.backgroundColor = UIColor.transparent
        
        // Sends a notification that the active timer is no longer being selected
        NotificationCenter.default.post(name: .didDeselectActiveTimer, object: nil)
    }
    
    @objc func newTimerScreen()
    {
        let newTimerScreen = NewTimerScreen()
        
        // Keeps the presenting "TimerCollectionViewController" VC in view beneath the presented "newTimerScreen" VC.
        newTimerScreen.modalPresentationStyle = .overFullScreen
        present(newTimerScreen, animated: true, completion: nil)
    }
    
}



//MARK: ---------- FIRESTORE FUNCTIONS ----------

extension TimerCollectionViewController
{
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
    
    @objc func timerIsRunning()     { isTimerRunning = true }
    @objc func timerIsNotRunning()  { isTimerRunning = false }
    
//    func saveCurrentTimer(timerID: String)
//    {
//        Timii().FSSaveSelectedTimerLog(timerID: timerID)
//    }
    
}


//extension TimerCollectionViewController : UIGestureRecognizerDelegate
//{
//    @objc func onDidLongPressTimer(gestureRecognizer : UILongPressGestureRecognizer!)
//    {
//        // On a long press this function triggers a modal popup that allows members to UPDATE the
//        // timer presses and DELETE the timer.
//        print("->onDidLongPressTimer")
//
//        if gestureRecognizer.state != UIGestureRecognizer.State.began { return }    // Trigger this function on BEGAN recognition of a long press
//
//        let p = gestureRecognizer.location(in: timerCollectionView)
//
//        if let indexPath = timerCollectionView?.indexPathForItem(at: p)
//        {
//            // get the cell at indexPath (the one you long pressed)
//            print("Let's UPDATE or DELETE this timer.")
//
//            let cell = timerCollectionView?.cellForItem(at: indexPath)
//
//            // do stuff with the cell
//
//
//
//        } else {
//            print("Could not find indexPath.")
//        }
//    }
//
//
//    @objc func onDidPressDeleteButton()
//    {
//        print("pressed Delete button")
//    }
//
//}

//extension UIView
//{
//    func highlightedCircle()
//    {
//        self.layer.cornerRadius = self.frame.width / 2
////        self.layer.
//        self.layer.masksToBounds = true
//    }
//
//}


// MARK: - UICollectionViewDelegate

extension TimerCollectionViewController
{
    // 3.26.19 - doesn't work yet. It triggers what is selected but doesn't show the ActiveTimerVC.
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        if selectedTimerIndexPath == indexPath {
//            selectedTimerIndexPath = nil
//        } else {
//            selectedTimerIndexPath = indexPath
//        }
//
//        return false
//    }
}
