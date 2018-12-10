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
 TODO: 12.1.18 - Add 'Add Timer' functionality to each timer button
 
 */

import Layout
import UIKit
import Firebase

private let images = [
    UIImage(named: "Add"),
    UIImage(named: "One"),
    UIImage(named: "Two"),
    UIImage(named: "Three"),
    UIImage(named: "Four"),
    UIImage(named: "Five"),
    UIImage(named: "Six"),
    UIImage(named: "Seven"),
    UIImage(named: "Eight"),
    UIImage(named: "Nine"),
]

class TimerCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, Ownable
{
    var db: Firestore!
    var timerTitles: [String] = [String](repeating: "", count: 9)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        db = Firestore.firestore()
        getTimers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getTimers()
    }
    
    @IBOutlet var timerCollectionView: UICollectionView? {
        didSet {
            timerCollectionView?.registerLayout(
                named: "TimerCollectionCell.xml",
                forCellReuseIdentifier: "standaloneCell"
            )
        }
    }
    
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "standaloneCell"
//        let identifier = (indexPath.row % 2 == 0) ? "templateCell" : "standaloneCell"
        let node = collectionView.dequeueReusableCellNode(withIdentifier: identifier, for: indexPath)
        
        // Sets default timer image when a timer is loaded
        let image: UIImage
        if timerTitles[indexPath.row] == "" {
            image = images[0]!
        } else {
            image = images[indexPath.row+1]!
        }
        
        node.setState([
            "row": indexPath.row,
            "title": timerTitles[indexPath.row],
            "image": image,
            ])
        
        return node.view as! UICollectionViewCell
    }
    
    @IBAction func onDidPressButton()
    {
        print("Pressed button.")
        newTimerScreen()
    }
    
    @objc func newTimerScreen()
    {
        let newTimerScreen = NewTimerScreen()
        
        // Keeps the presenting "TimerCollectionViewController" VC in view beneath the presented "newTimerScreen" VC.
        newTimerScreen.modalPresentationStyle = .overFullScreen
        present(newTimerScreen, animated: true, completion: nil)
    }
    
    var listenerDash: ListenerRegistration!
    
    func getTimers()
    {
        db.collection("Members").document(memberID).collection("Timers").getDocuments() { (querySnapshot, error) in
            if let err = error {
                print("Error getting document: \(err)")
            } else {
                for (index, document) in querySnapshot!.documents.enumerated()
                {
                    print("--->>>\(document.documentID) => \(document.data())")
                    let timerDoc = document.data()
                    self.timerTitles[index] = timerDoc["name"] as? String ?? ""
                }
                DispatchQueue.main.async { self.timerCollectionView?.reloadData() }
                print(self.timerTitles)  // delete
            }
        }
    }
}

