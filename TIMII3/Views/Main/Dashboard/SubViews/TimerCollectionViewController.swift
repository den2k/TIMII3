//
//  TimerCollectionViewController.swift
//  TIMII3
//
//  Created by Dennis Huang on 11/27/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/*

 TODO: 11.28.18 [DONE - 12.1.18] - Make this into a collection view. Created a temporary visual timer dashboard with a collection view.
 TODO: 12.1.18 [DONE 12.1.18] - Cleanup unnecessary code from previous collection layout.
 TODO: 12.1.18 [DONE 12.1.18] - Remove use of templateCell
 TODO: 12.1.18 [DONE 12.4.18] - Retrieve existing Timers and display them in Timer Collection
 TODO: 12.5.18 [DONE 12.5.18] - Add a default image for each retrieved timer. We have 3 now.
 TODO: 12.1.18 [DONE 12.22.18] - Add 'Add Timer' functionality only to empty timer button.
 TODO: 12.9.18 [DONE 12.13.18] - Limit timers to Max and fix reading more timers crashing
 TODO: 12.11.18 [DONE 12.13.18] - After adding new timers, refresh screen. Added observer to reload data.
 TODO: 12.13.18 [DONE 12.16.18] - Add Number of Timers Stats to Member document
 TODO: 12.17.18 [DONE 12.17.18] - Clear timer views upon new member login
 TODO: 12.13.18 [DONE 12.22.18] - Updated so newTimerScreen only shows with an empty Timer slot in didSelectItemAt. Limit the showing of New Timer Screen if user exceeds the number of timers allowed. Need to add stats into FS to do this.
 TODO: 12.13.18 - Delete timers with press and hold gesture to show delete dialog.
 TODO: 12.23.18 - Highlighted background to show selected timer is messedup. Fix.
 TODO: 12.24.18 [DONE 12.24.18] - Show only 1 Add Timer at a time. (Ellie)
 TODO: 12.24.18 - When NUMOFALLOWEDTIMERS is reached. Show $$$ Screen. (Ellie)
 
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

private let NUMOFALLOWEDTIMERS = 6

class TimerCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, Ownable
{
    var db: Firestore!
    
    var timerTitles: [String] = [String](repeating: "Add Timer", count: NUMOFALLOWEDTIMERS)
    var timerIDs: [String] = [String](repeating: "", count: NUMOFALLOWEDTIMERS)
    var timerSlotIsEmpty: [Bool] = [Bool](repeating: true, count: NUMOFALLOWEDTIMERS)
//    var activeTimers: [Int] = []
    
    // Used to store
    var numOfTimers: Int = 0

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        db = Firestore.firestore()
        readTimers()     // can probably safely delete this given viewWillAppear also calls it

        NotificationCenter.default.addObserver(self, selector: #selector(readTimers), name: .didCreateNewTimer, object: nil)
        
        
        // Add Long Press Gesture to delete
//        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onDidLongPressTimer))
//        lpgr.minimumPressDuration = 0.5
//        lpgr.delegate = self
//        lpgr.delaysTouchesBegan = true
//        timerCollectionView?.addGestureRecognizer(lpgr)
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        // Reset timer when it reappears.
        readTimers()
    }
    
    
    @IBOutlet var timerCollectionView: UICollectionView? {
        didSet {
            timerCollectionView?.registerLayout(
                named: "TimerCollectionCell.xml",
                forCellReuseIdentifier: "timerCollectionCell"
            )
        }
    }
    
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
//        return NUMOFALLOWEDTIMERS
        
        // This should display the Timers + 1 Add Timer slot
        return numOfTimers + 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier: String = "timerCollectionCell"
        
        // Sets default timer image when a timer is loaded
        let image: UIImage
        if timerSlotIsEmpty[indexPath.row] == true {
            image = add!
//            timerSlotIsEmpty[indexPath.row] = true
        } else {
            image = images[(indexPath.row) % 10]!
//            timerSlotIsEmpty[indexPath.row] = false
        }
        
//        let identifier = (indexPath.row % 2 == 0) ? "templateCell" : "standaloneCell"
        let node = collectionView.dequeueReusableCellNode(withIdentifier: identifier, for: indexPath)
        
        node.setState([
            "row": indexPath.row,
            "title": timerTitles[indexPath.row],
            "image": image,
            "timerIsEmpty": timerSlotIsEmpty[indexPath.row]
            ])
        
        return node.view as! UICollectionViewCell
    }
    
  
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
//        let cell : UICollectionViewCell = collectionView.cellForItem(at: indexPath as IndexPath)!
        
        if timerSlotIsEmpty[indexPath.row] == true {
            
            // An empty timer slot has been selected so show the newTimerScreen so a new timer can be created
//            cell.backgroundColor = UIColor.green
            newTimerScreen()
            
        } else {
            
            // A Member timer has been selected so show this timer in the ActiveTimer View Controller
//            cell.backgroundColor = UIColor.red

            let dict = [
                "index": indexPath.row,
                "timerID": timerIDs[indexPath.row],
                ] as [String : Any]
            
            NotificationCenter.default.post(name: .didSelectNewActiveTimer, object: nil, userInfo: dict)
        
        }
        
        print("Selected: \(indexPath.row)")
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
    
    @objc func readTimers()
    {
//        var timerCount: Int = 0
        
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


//extension TimerCollectionViewController: UIGestureRecognizerDelegate
//{
//    @objc func onDidLongPressTimer(gestureRecognizer : UILongPressGestureRecognizer)
//    {
//        print(">onDidLongPressTimer")
//        if gestureRecognizer.state != UIGestureRecognizer.State.began { return }
//
//        let p = gestureRecognizer.location(in: timerCollectionView)
//        if let indexPath = timerCollectionView?.indexPathForItem(at: p)
//        {
//            print("\(indexPath.row) Let's delete this timer.")
//        } else {
//            print("got nothing...")
//        }
//    }
//}
