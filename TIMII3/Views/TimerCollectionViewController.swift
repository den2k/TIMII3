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
 TODO: 12.1.18 - Add 'Add Timer' functionality to each timer button
 
 */

import Layout
import UIKit
import Firebase

private let images = [
    UIImage(named: "Add"),
]

class TimerCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, Ownable
{
    var db: Firestore!
    var timerTitles: [String] = [String](repeating: "", count: 12)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        db = Firestore.firestore()
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
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "standaloneCell"
//        let identifier = (indexPath.row % 2 == 0) ? "templateCell" : "standaloneCell"
        let node = collectionView.dequeueReusableCellNode(withIdentifier: identifier, for: indexPath)
        let image = images[indexPath.row % images.count]!
        
        node.setState([
            "row": indexPath.row,
            "title": timerTitles[indexPath.row],
            "image": image,
            "whiteImage": image.withRenderingMode(.alwaysOriginal),
            ])
        
        return node.view as! UICollectionViewCell
    }
    
    @IBAction func onDidPressButton()
    {
        print("Pressed button.")
        getTimers()
    }
    
    func getTimers()
    {
        db.collection("Members").document(memberID).collection("Timers").getDocuments() { (querySnapshot, error) in
            if let err = error {
                print("Error getting document: \(err)")
            } else {
                for (index, document) in querySnapshot!.documents.enumerated()
                {
                    print("--->>>\(document.documentID) => \(document.data())")
                    self.timerTitles[index] = document.documentID
                }
                DispatchQueue.main.async { self.timerCollectionView?.reloadData() }
                print(self.timerTitles)  // delete
            }
        }
    }
}

