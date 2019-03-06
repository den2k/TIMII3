//
//  ChangeTimerLogRecordViewController.swift
//  TIMII4
//
//  Created by Dennis Huang on 1/20/19.
//  Copyright © 2019 Autonomii. All rights reserved.
//
/** Note : This functions correctly and displays a Date picker and changes to user input.
    What remains is gluing the reading of a Log session to the picker and saving the changes.
  */
// 1.24.19 - Paused development on Change Timer Log Record function to work on VOICE activation instead.
//

import UIKit

class ChangeTimerLogRecordViewController : UIViewController
{

    var logStartTimeLabel: UILabel!
    var logEndTimeLabel: UILabel!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm a"
        
        // MARK: --- Timer Log ---
        /// Timer Log - Start Time
        logStartTimeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        logStartTimeLabel.center = CGPoint(x: 150, y: 50)
        logStartTimeLabel.textAlignment = .left
        logStartTimeLabel.textColor = UIColor.black
        logStartTimeLabel.backgroundColor = UIColor.white
        logStartTimeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: 365))
        self.view.addSubview(logStartTimeLabel)
        
        /// Timer Log - Start Time DatePicker
        let logStartTimeDatePicker: UIDatePicker = UIDatePicker()
        logStartTimeDatePicker.frame = CGRect(x: 0, y: 70, width: self.view.frame.width, height: 200)
        logStartTimeDatePicker.timeZone = NSTimeZone.local
        logStartTimeDatePicker.backgroundColor = UIColor.white
        logStartTimeDatePicker.addTarget(self, action: #selector(logStartTimeDatePickerValueChanged(_:)), for: .valueChanged)  // Add an event to call onDidChangeDate function when value is changed.
        self.view.addSubview(logStartTimeDatePicker)

        /// Timer Log - End Time
        logEndTimeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        logEndTimeLabel.center = CGPoint(x: 150, y: 300)
        logEndTimeLabel.textAlignment = .left
        logEndTimeLabel.textColor = UIColor.black
        logEndTimeLabel.backgroundColor = UIColor.white
        logEndTimeLabel.text = dateFormatter.string(from: Date(timeIntervalSinceNow: 0))
        self.view.addSubview(logEndTimeLabel)
        
        /// Timer Log - End Time DatePicker
        let logEndTimeDatePicker: UIDatePicker = UIDatePicker()
        logEndTimeDatePicker.frame = CGRect(x: 0, y: 320, width: self.view.frame.width, height: 200)
        logEndTimeDatePicker.timeZone = NSTimeZone.local
        logEndTimeDatePicker.backgroundColor = UIColor.white
        logEndTimeDatePicker.addTarget(self, action: #selector(logEndTimeDatePickerValueChanged(_:)), for: .valueChanged)  // Add an event to call onDidChangeDate function when value is changed.
        self.view.addSubview(logEndTimeDatePicker)

    }
    
    
    @objc func logStartTimeDatePickerValueChanged(_ sender: UIDatePicker)
    {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm a"
        logStartTimeLabel.text = dateFormatter.string(from: sender.date)
    }

    @objc func logEndTimeDatePickerValueChanged(_ sender: UIDatePicker)
    {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm a"
        logEndTimeLabel.text = dateFormatter.string(from: sender.date)
    }
    
}

//class ChangeTimerLogRecordViewController : UIViewController
//{
//    @IBOutlet weak var logRecordDatePicker: UIDatePicker!
//    {
//        didSet {
//            logRecordDatePicker?.minuteInterval = 5
////            logRecordDatePicker?.minimumDate = Date(timeIntervalSinceReferenceDate: 365*19*19*60*60)
////            logRecordDatePicker?.maximumDate = Date(timeIntervalSinceReferenceDate: 365*19*19*60*60 + 24*60*60)
//        }
//    }
//
//    @IBOutlet weak var selectedLogDateLabel: UILabel!
//
//    override func viewDidLoad()
//    {
//        super.viewDidLoad()
//
//        /// Class Variables
////        var logRecordDatePicker: UIDatePicker!
////        var readLogDate: Date
////        var readLogDateLable : UILabel!
//
//    }
//
//    /// Action for updating the Label that shows what the user changed the date too...
//    @IBAction func datePickerAction(sender: AnyObject)
//    {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
//        let strDate = dateFormatter.string(from: logRecordDatePicker.date)
//        selectedLogDateLabel.text = strDate
//    }
//
//
//}
//



