//
//  NewTimerViewController.swift
//  TIMII3
//
//  Created by Dennis Huang on 11/27/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
/*

 TODO: 11.28.18 [DONE - 12.1.18] - Make this into a collection view. Created a temporary visual timer dashboard with a collection view.
 TODO: 12.1.18 [DONE 12.1.18] - Cleanup unnecessary code from previous collection layout.
 TODO: 12.1.18 [DONE 12.1.18] - Remove use of templateCell
 TODO: 12.1.18 - Add 'Add Timer' functionality to each timer button
 
 */

import Layout
import UIKit

private let images = [
    UIImage(named: "Add"),
]

//private let images = [
//    UIImage(named: "One"),
//    UIImage(named: "Two"),
//    UIImage(named: "Three"),
//]

class NewTimerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{
    @IBOutlet var collectionView: UICollectionView? {
        didSet {
            collectionView?.registerLayout(
                named: "CollectionCell.xml",
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
            "image": image,
            "whiteImage": image.withRenderingMode(.alwaysOriginal),
            ])
        
        return node.view as! UICollectionViewCell
    }
}
