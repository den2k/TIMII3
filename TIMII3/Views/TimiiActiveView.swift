//
//  TimiiActiveViewController.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/29/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

import Foundation
import Layout

class TimiiActiveViewController: UIViewController
{
    // Set FS fields to "blank" so no errors show up waiting for data retrival
    // 10.30.18 - Outlets must be passed to Layout using UIViewControllers. Cannot use class defined UIViews.
    @IBOutlet var TimiiActiveNode: LayoutNode? {
        didSet {
            TimiiActiveNode?.setState([
                "name"      : "",
                "minute"    : "",
                "second"    : "",
                "isRunning" : "",
            ])
        }
    }
}
//    override func viewWillAppear(_ animated: Bool)
//    {
//        super.viewWillAppear(animated)
//        self.TimiiActiveNode?.setState([
//            "name"    : "name: 11",
//            "minute"  : "min: 11",
//            "second"  : "sec: 11",
//            "isRunning" : "isRunning: yes"
//            ])
//
//        self.loadLayout(
//            named: "TimiiActiveViewController.xml",
//            state:[
//                "name"      : "name: 22",
//                "minute"    : "min: 22",
//                "second"    : "sec: 22",
//                "isRunning" : "isRunning: no",
//            ]
//        )
//    }
