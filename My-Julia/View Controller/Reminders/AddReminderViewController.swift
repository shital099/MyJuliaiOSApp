//
//  AddReminderViewController.swift
//  sections by dates
//
//  Created by Apoorv Mote on 08/12/15.
//  Copyright © 2015 Apoorv Mote. All rights reserved.
//

import UIKit

class AddReminderViewController: UIViewController , TKAlertDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var customTimeDoneBtn: UIButton!

    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var timeDatePicker: UIDatePicker!

    var alert : TKAlert!
    @IBOutlet weak var timeCustomView: UIView!
    @IBOutlet weak var dateCustomView: UIView!
    var time = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.timeButton.layer.borderWidth = 1
        self.timeButton.layer.borderColor = UIColor.lightGray.cgColor
        self.timeButton.layer.cornerRadius = 3.0
        self.customTimeDoneBtn.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    // MARK: - Button Action Methods

    @IBAction func textFieldEditing(_ sender: UITextField) {
        
        //      sender.inputView = self.dateCustomView
        self.dateTextField.inputView = dateCustomView
        //        timeDatePicker.addTarget(self, action: Selector("datePickerValueChanged:"), for: UIControlEvents.valueChanged)
    }

    @IBAction func addToReminderTime() {
        
        self.timePicker.isEnabled = true
        dateTextField.resignFirstResponder()

        if alert == nil {
            // >> alert-custom-content-swift
            alert = TKAlert()
            alert.style.headerHeight = 0
            alert.tintColor = UIColor(red: 0.5, green: 0.7, blue: 0.2, alpha: 1)
            alert.customFrame = CGRect(x: ((self.view.frame.size.width - 320)/2) + 270, y: (self.view.frame.size.height - 270)/2, width: 320, height: 270)
            
                        self.timeCustomView.frame = CGRect(x: 0, y: 0, width: self.timeCustomView.frame.size.width, height: self.timeCustomView.frame.size.height)
                        alert.contentView.addSubview(timeCustomView)
            //        alert.customFrame = CGRect(x: (self.view.frame.size.width - 300)/2, y: 100, width: 300, height: 250)
            //        let view = AlertCustomContentView(frame: CGRect(x: 0, y: 0, width: 300, height: 210))
            //        alert.contentView.addSubview(view)
            // << alert-custom-content-swift
            
            //          alert.style.centerFrame = false
            alert.style.centerFrame = true
            
            // >> alert-animation-swift
            alert.style.showAnimation = TKAlertAnimation.scale;
            alert.style.dismissAnimation = TKAlertAnimation.scale;
            // << alert-animation-swift
            
            // >> alert-tint-dim-swift
            alert.style.backgroundDimAlpha = 0.3;
            alert.style.backgroundTintColor = UIColor.gray
            // << alert-tint-dim-swift
            
            // >> alert-anim-duration-swift
            alert.animationDuration = 0.5;
            // << alert-anim-duration-swift

            alert.delegate = self

            alert.addAction(withTitle: "Cancel") { (TKAlert, TKAlertAction) -> Bool in
                return true
            }
        }
        alert.show(true)
    }
    
    @IBAction func onClickOfAddCustomReminderBtn(sender: AnyObject) {
        
        let outputFormatter : DateFormatter = DateFormatter();
        outputFormatter.dateFormat = "HH"
        let hours = Int(outputFormatter.string(from: timeDatePicker.date))
        outputFormatter.dateFormat = "mm"
        let mins = hours!*60 + Int(outputFormatter.string(from: timeDatePicker.date))!

        self.timeTextField.setTitle(String(format:" %d min",mins), for: .normal)

        alert.dismiss(true)
    }
    
    @IBAction func chooseReminderTimeAction(sender: AnyObject) {
        
        self.timeDatePicker.isEnabled = false

        //Add before time of reminder
        switch (sender as AnyObject).tag {
        case 100:
            time = 5
            break
        case 200:
            time = 15
            break
        case 300:
            self.timeDatePicker.isEnabled = true
            self.customTimeDoneBtn.isEnabled = true
            break
        default:
            time = 0
            break
        }
        
        if sender.tag != 300 {
            self.timeTextField.setTitle(String(format:" %d min",time), for: .normal)
            alert.dismiss(true)
        }
    }
    
    @IBAction func saveBtnClick (sender: UIButton){

        if sender.tag == 100 {
            let outputFormatter : DateFormatter = DateFormatter();
            outputFormatter.dateFormat = "dd-MM-YYYY hh:mm aa"
            self.dateTextField.text = outputFormatter.string(from: timeDatePicker.date)
        }

        dateTextField.resignFirstResponder()
    }

    @IBAction func saveReminderBtnClick (sender: UIButton){

        if (self.titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: "Please enter reminder title", vc: self)
            return
        }
        else if (self.dateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: "Select reminder date", vc: self)
            return
        }

        self.saveReminderIntoDB(time: self.time)
    }


    // MARK: - Database Methods

    func saveReminderIntoDB(time : Int) {
        self.customTimeDoneBtn.isEnabled = false

        let reminder = ReminderModel()
        
        reminder.title = titleTextField.text!
        reminder.reminderTime = String(time)

        let outputFormatter : DateFormatter = DateFormatter();
        outputFormatter.dateFormat = "dd-MM-YYYY"
        reminder.sortDate = outputFormatter.string(from: timePicker.date)
        outputFormatter.dateFormat = "HH:mm:ss"
        reminder.activityStartTime = outputFormatter.string(from: timePicker.date)
        reminder.activityEndTime = outputFormatter.string(from: timePicker.date)

        DBManager.sharedInstance.saveNewReminderDataIntoDB(reminder: reminder)
        
        alert.dismiss(true)
        
        let store: EKEventStore = EKEventStore()
        
        //Add reminder into calender
        store.requestAccess(to: .event) {(granted, error) in
            if !granted {
                return
            }
            let event = EKEvent(eventStore: store)
            
            event.title = self.titleTextField.text!

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" //Your date format
             dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
//            let startdate = dateFormatter.date(from: self.agendaModel.startDate)
//            let endDate = dateFormatter.date(from: self.agendaModel.endDate)
            
//            event.startDate = startdate!
//            event.endDate = endDate!
//
//            print("event start", event.startDate )
//            print("event end", event.endDate )
//            
//            event.startDate = CommonModel.sharedInstance.getStringIntoDate(dateStr: self.agendaModel.startDate) as Date
//            event.endDate = CommonModel.sharedInstance.getStringIntoDate(dateStr: self.agendaModel.endDate) as Date
            // event.startDate.dateByAddingTimeInterval(60*60) //1 hour long meeting
            event.calendar = store.defaultCalendarForNewEvents
            
            let interval = TimeInterval(-(60 * time));
            let alarm = EKAlarm(relativeOffset:interval)
            event.alarms = [alarm]
            
            //Add reminder into calender
            do {
                try store.save(event, span: .thisEvent, commit: true)
                print(event.eventIdentifier) //save event id to access this particular event later
            } catch {
                // Display error to user
            }
        }

        self.navigationController?.popViewController(animated: true)
    }

    func datePickerValueChanged(sender : UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.medium
        
        let strDate = dateFormatter.string(from: timeDatePicker.date)
        dateTextField.text = strDate
    }

    // MARK: - Reminder view Delegate Methods

    func alertDidDismiss(_ alert: TKAlert) {
        self.customTimeDoneBtn.isEnabled = false
    }
}
