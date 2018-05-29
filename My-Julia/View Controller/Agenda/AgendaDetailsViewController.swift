//
//  AgendaDetailsViewController.swift
//  My-Julia
//
//  Created by GCO on 5/11/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class AgendaDetailsViewController: UIViewController,UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableviewObj: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var reminderCustomView: UIView!
    @IBOutlet weak var reminderDatePicker: UIDatePicker!
    @IBOutlet weak var customTimeDoneBtn: UIButton!

    let picker = UIImagePickerController()
    var agendaModel = AgendaModel()
    var isMySchedules : Bool = false
    var note = Notes()
    var reminderStatus : Bool = false
    var alert : TKAlert!
    var isRefresh : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Details"
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)

        // Do any additional setup after loading the view.
        
        //Update dyanamic height of tableview cell
        tableviewObj.estimatedRowHeight = 1000
        tableviewObj.rowHeight = UITableViewAutomaticDimension
        
        //Remove extra lines from tableview
        tableviewObj.tableFooterView = UIView()
        
        //Fetch data from json
       // agendaModel.speakers = CommonModel.sharedInstance.parseSpeakerData() as! [PersonModel]
        
        //Register header cell
        tableviewObj.register(UINib(nibName: "CustomHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderCellId")
       
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableviewObj)

        //Fetch agenda details
        agendaModel = DBManager.sharedInstance.fetchActivityDetailsFromDB(activityId: agendaModel.activityId)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {


        //Check reminder added or not
        reminderStatus = DBManager.sharedInstance.isReminderAddedIntoDB(activityId: agendaModel.activityId)

        if isRefresh == true {
            //Fetch agenda details
            agendaModel = DBManager.sharedInstance.fetchActivityDetailsFromDB(activityId: agendaModel.activityId)
           // self.tableviewObj.reloadData()
            isRefresh = false
        }
        else {
            //Fetch note data
            print("activity id : ",agendaModel.activityId)
            note = DBManager.sharedInstance.fetchNotesFromDB(activityId: agendaModel.activityId)
           // self.refreshTableStatus()
        }
        self.tableviewObj.reloadData()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destinationVC = segue.destination as! AddNoteViewController
        
        if segue.identifier == "AddNoteSegue" {
            destinationVC.isFromMySchedule = true
            destinationVC.isNewNote = false
            self.isRefresh = false

            //If note not yet created
            if (note.id == nil) {
                note.titleStr = agendaModel.activityName
                note.sessionId = agendaModel.sessionId
                note.activityId = agendaModel.activityId
            }
            destinationVC.noteModel = note
        }
    }
    
    //MARK:- WebService Methods
    
    func getActivityDetailsData() {
        
        NetworkingHelper.getRequestFromUrl(name:Agenda_Details_url,  urlString: Agenda_Details_url.appendingFormat(self.agendaModel.activityId), callback: { [weak self] response in
            
            if response is NSDictionary {
                let dict = response as! NSDictionary
                if (dict.value(forKey:"speaker") as? NSNull) == nil {
                    self?.agendaModel = DBManager.sharedInstance.fetchActivityDetailsFromDB(activityId:(self?.agendaModel.activityId)!)
                }
            }
            self?.tableviewObj.reloadData()
        }, errorBack: { error in
            NSLog("error : %@", error)
        })
    }

    // MARK: - Button Action Methods
    
    @IBAction func onClickOfAddToScheduleBtn(sender: AnyObject) {
        
        if agendaModel.isAddedToSchedule {
            CommonModel.sharedInstance.showAlertNotification(view: self.view, title: Agenda_Sucess, message: Deleted_Agenda_Text, alertType: TKAlertType.TKAlertTypeError.rawValue)
        }
        else {
            CommonModel.sharedInstance.showAlertNotification(view: self.view, title: Agenda_Sucess, message: Added_Agenda_Text, alertType: TKAlertType.TKAlertTypeSucess.rawValue)
        }
        
        //add this activity to my schedule
        agendaModel.isAddedToSchedule = !agendaModel.isAddedToSchedule
        DBManager.sharedInstance.addToMyScheduleDataIntoDB(model: agendaModel)
        
        let indexPath = IndexPath(row: 2, section: 0)
        tableviewObj.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)

        //        let alert = UIAlertController(title: "Success!", message: "Schedule Added Successfully", preferredStyle: UIAlertControllerStyle.alert)
        //        // add an action (button)
        //        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        //        // show the alert
        //        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addToReminder() {
        
        self.reminderDatePicker.isEnabled = false

        if alert == nil {
            // >> alert-custom-content-swift
            alert = TKAlert()
            alert.style.headerHeight = 0
            alert.tintColor = UIColor(red: 0.5, green: 0.7, blue: 0.2, alpha: 1)
            alert.customFrame = CGRect(x: ((self.view.frame.size.width - 320)/2) + 270, y: (self.view.frame.size.height - 270)/2, width: 320, height: 270)
            
            self.reminderCustomView.frame = CGRect(x: 0, y: 0, width: self.reminderCustomView.frame.size.width, height: self.reminderCustomView.frame.size.height)
            alert.contentView.addSubview(reminderCustomView)
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
            
            alert.addAction(withTitle: "Cancel") { (TKAlert, TKAlertAction) -> Bool in
                return true
            }
        }
        alert.show(true)
    }
    
    @IBAction func onClickOfAddCustomReminderBtn(sender: AnyObject) {
        
        let outputFormatter : DateFormatter = DateFormatter();
        outputFormatter.dateFormat = "HH"
        let hours = Int(outputFormatter.string(from: reminderDatePicker.date))
        outputFormatter.dateFormat = "mm"
        let mins = hours!*60 + Int(outputFormatter.string(from: reminderDatePicker.date))!

        self.saveReminderIntoDB(time: mins)
    }

    @IBAction func chooseReminderTimeAction(sender: AnyObject) {
        
        self.reminderDatePicker.isEnabled = false
        
        var time = 0
        
        //Add before time of reminder
        switch (sender as AnyObject).tag {
        case 100:
            time = 5
            let alert = UIAlertController(title: "Success!", message: "Reminder Added Successfully", preferredStyle: UIAlertControllerStyle.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
            break
           
        case 200:
            time = 15
            let alert = UIAlertController(title: "Success!", message: "Reminder Added Successfully", preferredStyle: UIAlertControllerStyle.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
            break
        case 300:
            self.reminderDatePicker.isEnabled = true
            self.customTimeDoneBtn.isEnabled = true
            let alert = UIAlertController(title: "Success!", message: "Reminder Added Successfully", preferredStyle: UIAlertControllerStyle.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
            break
        default:
            time = 0
            break
        }
        
        if sender.tag != 300 {
            self.saveReminderIntoDB(time: time)
        }
    }
    
    func saveReminderIntoDB(time : Int) {

        self.customTimeDoneBtn.isEnabled = false
        let reminder = ReminderModel()
        reminder.title = agendaModel.activityName
        reminder.message = agendaModel.location
        reminder.sortDate = agendaModel.startActivityDate
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        let date = dateFormatter.date(from: agendaModel.startActivityDate)
//        dateFormatter.dateFormat = "dd-MM-yyyy"
//        reminder.sortDate = dateFormatter.string(from: date!)
        reminder.activityStartTime = agendaModel.startActivityDate
        reminder.activityEndTime = agendaModel.endActivityDate
        reminder.sessionId = agendaModel.sessionId
        reminder.activityId = agendaModel.activityId
        reminder.reminderTime = String(time)
        
        DBManager.sharedInstance.saveNewReminderDataIntoDB(reminder: reminder)
        
        reminderStatus = true
        alert.dismiss(true)
        self.refreshTableStatus()
        
        let store: EKEventStore = EKEventStore()
        
        //Add reminder into calender
        store.requestAccess(to: .event) {(granted, error) in
            if !granted {
                return
            }
            let event = EKEvent(eventStore: store)
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//            event.startDate = dateFormatter.date(from: self.agendaModel.startActivityDate)!
//            event.endDate = dateFormatter.date(from: self.agendaModel.endActivityDate)!
            event.title = self.agendaModel.activityName
            event.accessibilityValue = self.agendaModel.activityId as String

            event.startDate = CommonModel.sharedInstance.getStringIntoDate(dateStr: self.agendaModel.startActivityDate) as Date
            event.endDate = CommonModel.sharedInstance.getStringIntoDate(dateStr: self.agendaModel.endActivityDate) as Date
            event.calendar = store.defaultCalendarForNewEvents
            let interval = TimeInterval(-(60 * time));
            let alarm = EKAlarm(relativeOffset:interval)
            event.alarms = [alarm]

            print("event start", event.startDate )
            print("event end", event.endDate  )

            //Add reminder into calender
            do {
                let predicate = store.predicateForEvents(withStart: event.startDate, end: event.endDate, calendars: nil)
                let existingEvents = store.events(matching: predicate)
                for singleEvent in existingEvents {
                    if singleEvent.title == self.agendaModel.activityName {
                        // Event exist
                        print("Reminder added..")
                        try store.remove(singleEvent, span: .thisEvent, commit: true)
                    }
                }

                try store.save(event, span: .thisEvent, commit: true)
            } catch {
                // Display error to user
            }
        }
    }
    
    @IBAction func onClickOfCameraBtn(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
             let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
    imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
    imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
            
            let indexPath = IndexPath(row: 2, section: 0)
                    tableviewObj.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
              }
        }
    
    func refreshTableStatus() {
        
        let indexPath = IndexPath(row: 2, section: 0)
        tableviewObj.reloadRows(at: [indexPath as IndexPath], with: .none)
    }
    
    
    //MARK: - UIImagePickerController Delegates Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
       
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            if mediaType  == "public.image" {
            }
            
            if mediaType == "public.movie" {
                print("Video Selected")
                return
            }
        }
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PostPhotoViewController") as! PostPhotoViewController
        viewController.capturedPhoto = chosenImage
        let imageNo = Int(arc4random_uniform(1000) + 1)
        viewController.imageName = "CapturedPhoto".appendingFormat("%d", imageNo)
        
        self.navigationController?.pushViewController(viewController, animated: true)
        dismiss(animated:true, completion: nil) //5
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil) //5
    }
    
    // MARK: - TableView DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //Hide session feedback for future activity
        if agendaModel.isFutureActivity == true && agendaModel.activityStatus == false {
            return 3
        }
        else {
            return 4
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        else if section == 1 {
            if self.agendaModel.speakers.count == 0 {
                return 1
            }
            else {
                return self.agendaModel.speakers.count
            }
        }
        else if section == 2 && self.agendaModel.descText != nil {
            return 1
        }
        else if section == 3 {
            return 1
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 0 {
            //Get Idetifier
            if indexPath.row == 0 {
                return UITableViewAutomaticDimension
               // return 130
            }
            else if indexPath.row == 1 {
                return 50
            }
            else if indexPath.row == 2 {
                return 70
            }
        }
        else if indexPath.section == 1 || indexPath.section == 3 {
            return 65
        }
        
        return UITableViewAutomaticDimension

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      
        if section == 0 {
            return 0
        }
//        else if section == 1 && agendaModel.speakers.count == 0 {
//            return 0
//        }
        else {
            return 23
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderCellId") as! CustomHeaderView
        
        headerView.backgroundColor = AppTheme.sharedInstance.menuBackgroundColor.darker(by: 15)
        
        if section == 0 {
            headerView.headerLabel.text = ""
        }
        if section == 1 {
            headerView.headerLabel.text = "SPEAKERS"
        }
        else if section == 2 {
            headerView.headerLabel.text = "DESCRIPTION"
        }
        else {
            if self.agendaModel.activityStatus == true {
                headerView.headerLabel.text = "SESSION QUESTIONS"
            }
            else {
                headerView.headerLabel.text = "SESSION FEEDBACK"
            }
        }
        
        headerView.setGradientColor()
        
        return headerView
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            var cellIdentifier : String = ""
            
            //Get Idetifier
            if indexPath.row == 0 {
                cellIdentifier = "InfoIdentifier"
            }
            else if indexPath.row == 1 {
                cellIdentifier = "AddressIdentifier"
            }
            else if indexPath.row == 2 {
                cellIdentifier = "NoteIdentifier"
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AgendaDetailsCell
            cell.backgroundColor = cell.contentView.backgroundColor;

            if indexPath.row == 0
            {
                cell.nameLabel?.text = agendaModel.activityName
                cell.dateLbl.text = CommonModel.sharedInstance.getAgendaDate(dateStr: agendaModel.startActivityDate).appendingFormat(" - %@", CommonModel.sharedInstance.getAgendaDate(dateStr: agendaModel.endActivityDate))
            }
            else if indexPath.row == 1 {
                cell.addressLabel?.text = agendaModel.location
            }
            else if indexPath.row == 2 {
                
                if isMySchedulesPresent {
                    //Check activity added into schedule
                    if agendaModel.isAddedToSchedule {
                        cell.addScheduleBtn.isSelected = true
                    }
                    else {
                        cell.addScheduleBtn.isSelected = false
                    }
                }else {
                    cell.addScheduleBtn.isEnabled = false
                    cell.addScheduleBtn.alpha = 0.5

//                    cell.addScheduleBtn.width = 0
//                    cell.addScheduleBtn.updateConstraints()
//                    cell.addScheduleBtn.updateConstraintsIfNeeded()
                }
                
                if isMyNotesPresent {
                    //Check note added
                    if (note.id != nil) {
                        cell.createNoteBtn.isSelected = true
                    }
                    else {
                        cell.createNoteBtn.isSelected = false
                    }
                }else {
                    cell.createNoteBtn.isEnabled = false
                    cell.createNoteBtn.alpha = 0.5

//                    cell.createNoteBtn.width = 0
//                    cell.createNoteBtn.updateConstraints()
//                    cell.createNoteBtn.updateConstraintsIfNeeded()
                }
                
                if isRemainderPresent {
                    //Check reminder added
                    if reminderStatus {
                        cell.addReminderBtn.isSelected = true
                    }
                }else {
                    cell.addReminderBtn.isEnabled = false
                    cell.addReminderBtn.alpha = 0.5

//                    cell.addReminderBtn.width = 0
//                    cell.addReminderBtn.updateConstraints()
//                    cell.addReminderBtn.updateConstraintsIfNeeded()
                }
                
//                if !isActivityFeedPresent {
//                    cell.cameraBtn.isEnabled = false
//
////                    cell.cameraBtn.width = 0
////                    cell.cameraBtn.updateConstraints()
////                    cell.cameraBtn.updateConstraintsIfNeeded()
//                }
            }
            return cell
        }
        else if indexPath.section == 1 {
            if agendaModel.speakers.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoSpeakerCell", for: indexPath)
                cell.contentView.backgroundColor = .clear
                cell.backgroundColor = .clear
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! SpeakerCustomCell
                cell.backgroundColor = .clear
                cell.contentView.backgroundColor = .clear

                let speaker = agendaModel.speakers[indexPath.row] as PersonModel
                
                cell.nameLabel!.text = speaker.name
                cell.designationLabel.text = speaker.designation
                if speaker.privacySetting == true {
                    if !speaker.iconUrl.isEmpty {
                        cell.imageview.sd_setImage(with: URL(string:speaker.iconUrl), placeholderImage: #imageLiteral(resourceName: "user"))
                        cell.imageview?.layer.cornerRadius = cell.imageview.frame.size.height/2
                        cell.imageview.clipsToBounds = true
                    }
                }
                else {
                    cell.imageview.image = #imageLiteral(resourceName: "user")
                }

                return cell
            }
        }
        else if indexPath.section == 2 {
           
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescIdentifier", for: indexPath) as! AgendaDetailsCell
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            if agendaModel.descText == "" {
                cell.descriptionLabel.text = " - "
            }
            else {
                cell.descriptionLabel.text = agendaModel.descText
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SendFeedbackCell", for: indexPath) as! SendFeedbackCell
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            if self.agendaModel.activityStatus == true {
                cell.titleLabel.text = "Ask Questions"
                cell.iconImg.image = #imageLiteral(resourceName: "askquestion")
            }
            else {
                cell.titleLabel.text = "Send Feedback"
                cell.iconImg.image = #imageLiteral(resourceName: "feedback")
            }
            cell.bgView.backgroundColor = .clear
            cell.bgView.layer.borderColor = AppTheme.sharedInstance.backgroundColor.darker(by: 10)?.cgColor
            cell.bgView.layer.cornerRadius = 5.0
            cell.bgView.layer.borderWidth = 1.0

            return cell
        }
    }
    
    // MARK: - TableView Delegate Methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Show speaker details
        if indexPath.section == 1 {
            
//            let viewController = storyboard?.instantiateViewController(withIdentifier: "SpeakerDetailsViewController") as! SpeakerDetailsViewController
//            viewController.personModel = self.agendaModel.speakers[indexPath.row]
//            self.navigationController?.pushViewController(viewController, animated: true)
            
            if self.agendaModel.speakers.count != 0 {
                let viewController = storyboard?.instantiateViewController(withIdentifier: "AttendeeDetailsViewController") as! AttendeeDetailsViewController
                viewController.personModel = self.agendaModel.speakers[indexPath.row]
                viewController.isSpeakerDetails = true
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        else if indexPath.section == 3 {
            
            self.isRefresh = true

            if self.agendaModel.activityStatus == true {
                let model = SessionsModel()
                model.id = self.agendaModel.sessionId
                model.sessionId = self.agendaModel.sessionId
                model.activitySessionId = self.agendaModel.activitySessionId
                model.activityId = self.agendaModel.activityId
                model.activityName = self.agendaModel.activityName
                model.agendaId = self.agendaModel.agendaId
                model.agendaName = self.agendaModel.agendaName
                model.startActivityDate = self.agendaModel.startActivityDate
                model.endActivityDate = self.agendaModel.endActivityDate
                model.sortActivityDate = self.agendaModel.sortDate
                model.day = self.agendaModel.day
                model.location = self.agendaModel.location
                model.startTime =  self.agendaModel.startTime
                model.endTime =  self.agendaModel.endTime
                model.isActive = true

                let viewController = storyboard?.instantiateViewController(withIdentifier: "QuestionsViewController") as! QuestionsViewController
                viewController.sessionModel = model
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            else {
                let viewController = storyboard?.instantiateViewController(withIdentifier: "ActivityFeedbackViewController") as! ActivityFeedbackViewController
                viewController.activityId = self.agendaModel.activityId
                viewController.isAgendaDetail = true
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }

    // MARK: - Reminder view Delegate Methods

    func alertDidDismiss(_ alert: TKAlert) {
        self.customTimeDoneBtn.isEnabled = false
    }
}

// MARK: - Custom Cell Classes

class AgendaDetailsCell: UITableViewCell {
    
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var dateLbl:UILabel!
    @IBOutlet var addressLabel:UILabel!
    @IBOutlet var createNoteBtn:UIButton!
    @IBOutlet var addReminderBtn:UIButton!
    @IBOutlet var addScheduleBtn:UIButton!
    @IBOutlet var cameraBtn:UIButton!
    @IBOutlet var descriptionLabel:UILabel!
    
}

class SendFeedbackCell: UITableViewCell {
    
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var bgView:UIView!
    @IBOutlet var iconImg:UIImageView!
}
