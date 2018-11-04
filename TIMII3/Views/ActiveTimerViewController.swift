//
//  ActiveTimerViewController.swift
//  TIMII3
//
//  Created by Dennis Huang on 10/29/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//
// TODO: 11.3.18 - delete testing VC properties timer1
// TODO: 11.3.18 [DONE - 11.3.18] - Save time results to Firestore

import Foundation
import Layout

class ActiveTimerViewController: UIViewController
{
    
    // ViewController properties
//    var timer1 = Timii(name: "History", description: "History 101 for Ellie")
    var timer1 = Timii(name: "English", description: "English 201 for Eaton")

    // viewDidLoad is called purely to trigger an updateView of this VC every second.
    override func viewDidLoad() {
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: (#selector(updateView)), userInfo: nil, repeats: true)
    }
    
    // This is to initialize FS fields to a value so no errors show up waiting for data retrival
    // 10.30.18 - Outlets must be passed to Layout using UIViewControllers. Cannot use class defined UIViews.
    @IBOutlet var ActiveTimerNode: LayoutNode? {
        didSet {
            ActiveTimerNode?.setState([
                "name"              : timer1.name,
                "hour"              : timer1.hours,
                "minute"            : timer1.minutes,
                "second"            : timer1.seconds,
                "isTimerRunning"    : timer1.isTimerRunning,
            ])
        }
    }
    
    @IBAction func toggleTimerButton()
    {
        timer1.toggleTimer()
        timer1.FSSaveTimerLog()
        updateView()
    }
    
    @objc func updateView()
    {
        /*
        Calling setState() on a LayoutNode after it has been created
        will trigger an update. The update causes all expressions in
        that node and its children to be re-evaluated.
         */
        
        self.ActiveTimerNode?.setState([
            "name"              : timer1.name,
            "hour"              : timer1.hours,
            "minute"            : timer1.minutes,
            "second"            : timer1.seconds,
            "isTimerRunning"    : timer1.isTimerRunning,
        ])
    }
}
