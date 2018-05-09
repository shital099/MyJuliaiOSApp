//
//  AttendeeDetailsViewController.swift
//  My-Julia
//
//  Created by GCO on 24/04/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class AttendeeDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableViewObj: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    
    var nameStr: String?
    var imgStr: String?
    var personModel : PersonModel!
    var isSpeakerDetails : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Details"

        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Update dyanamic height of tableview cell
        tableViewObj.estimatedRowHeight = 400
        tableViewObj.rowHeight = UITableViewAutomaticDimension
        
        //Register header cell
        tableViewObj.register(UINib(nibName: "CustomHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderCellId")

        if isSpeakerDetails {
           // self.title = "Speaker Details"
            //Fetch details from Sqlite database
            personModel = DBManager.sharedInstance.fetchSpeakersDetailsFromDB(speakerId: personModel.speakerId, attendeeId: self.personModel.personId)
            
            //Fetch details from server save into db
            self.getSpeakerDetailsData()
        }
        else {
           // self.title = "Attendee Details"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
//        if segue.identifier == "ChatIdentifierSegue" {
//            let destinationVC = segue.destination as! ChatViewController
//          //  destinationVC.userName = personModel.name
//        }
    }
    
    //MARK:- WebService Methods
    
    func getSpeakerDetailsData() {
        
        NetworkingHelper.getRequestFromUrl(name:Speakers_Details_url,  urlString: Speakers_Details_url.appendingFormat(self.personModel.speakerId), callback: { response in
            
            self.personModel = DBManager.sharedInstance.fetchSpeakersDetailsFromDB(speakerId: self.personModel.speakerId, attendeeId: self.personModel.personId)
            
            self.tableViewObj.reloadData()
        }, errorBack: { error in
        })
    }
    // MARK: - Button Action Methods
    
    @objc func onClickOfCallBtn() {
        
        if let url = NSURL(string: "tel://\(personModel.contactNo)"), UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    @objc func onClickOfChatBtn() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        let cModel = ChatGroupModel()
        cModel.groupId = personModel.personId
        cModel.fromId = EventData.sharedInstance.attendeeId
        cModel.name = personModel.name
        cModel.iconUrl = personModel.iconUrl
        cModel.isGroupChat = false
        vc.chatGroupModel = cModel
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    // MARK: - UITableView Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSpeakerDetails {
            return 4
        }
        else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        if section == 0 {
//            return 1
//        }
//        else if section == 1 &&  (personModel.contactNo != "" || personModel.email != "" ){
//            return 1
//        }
//        else if section == 2 && personModel.bioInfo != "" {
//            return 1
//        }
//        else {
//            return 0
//        }
        if self.isSpeakerDetails == true && section == 3 {
            if personModel.activities.count == 0 {
                return 1
            }
            else {
                return self.personModel.activities.count
            }
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        //Get Idetifier
        if indexPath.section == 0  {
            //If speaker details and logged in attendee profile, hide chat and call buttons
//            if isSpeakerDetails == true && self.personModel.personId == AttendeeInfo.sharedInstance.attendeeId {
//                return 185
//            }
//            else {
//                return 250
//            }
            
            return UITableViewAutomaticDimension
        }
        else if indexPath.section == 1 {
            return 150
        }
        else {
            return UITableViewAutomaticDimension
        }
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        
        var currHeight:CGFloat!
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 21))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        currHeight = label.frame.height
        label.removeFromSuperview()
        
        return currHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       
//        if section == 1 &&  (personModel.contactNo != "" || personModel.email != "" ){
//            return 23
//        }
        if section == 0 {
            return 0
        }
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
        else if section == 1 {
            headerView.headerLabel.text = " INFORMATION"
        }
        else if section == 2 {
            headerView.headerLabel.text = " DESCRIPTION"
        }
        else if section == 3 && self.isSpeakerDetails == true {
            headerView.headerLabel.text = " SESSIONS"
        }
        
        headerView.setGradientColor()
        
        return headerView
    }
    
    //    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    //
    //        let header = view as! UITableViewHeaderFooterView
    //        header.contentView.backgroundColor = AppTheme.sharedInstance.backgroundColor.darker(by: 5)
    //
    //        if let textlabel = header.textLabel {
    //            textlabel.font = textlabel.font.withSize(12)
    //        }
    //    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : AttendeeDetailsCell!
        var cellIdentifier : String = ""
        //Get Idetifier
        if indexPath.section == 0 {
            //If speaker details and logged in attendee profile, hide chat and call buttons
            if isSpeakerDetails == true && self.personModel.personId == AttendeeInfo.sharedInstance.attendeeId {
                cellIdentifier = "SpeakerInfoCell"
            }
            else {
                cellIdentifier = "PersonalInfoCell"
            }
        }
        else if indexPath.section == 1 {
            cellIdentifier = "ContactInfoCell"
        }
        else if indexPath.section == 2 {
            cellIdentifier = "BioInfoCell"
        }
        
        if indexPath.section == 0
        {
            return self.configureProfileCell(cellIdentifier: cellIdentifier, indexPath: indexPath)
        }
        else if indexPath.section == 1 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AttendeeDetailsCell
            cell.backgroundColor = cell.contentView.backgroundColor;

            if personModel.privacySetting == true {
                cell.mobileLabel?.text = personModel.contactNo
                cell.emailLabel.text = personModel.email
            }
            else {
                cell.mobileLabel?.text = " - "
                cell.emailLabel.text = " - "
            }
        }
        else if indexPath.section == 2 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AttendeeDetailsCell
            cell.backgroundColor = cell.contentView.backgroundColor;

            if personModel.bioInfo != "" {
                cell.descriptionLabel.text = personModel.bioInfo
            }
            else {
                cell.descriptionLabel?.text = " - "
            }
        }
            //Show activities when speaker details shows
        else  if indexPath.section == 3 && self.isSpeakerDetails == true {
            if personModel.activities.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoActivityCell", for: indexPath)
                cell.backgroundColor = cell.contentView.backgroundColor;
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AgendaCustomCell", for: indexPath) as! AgendaCustomCell
                cell.backgroundColor = cell.contentView.backgroundColor;
                
                let model = self.personModel.activities[indexPath.row] as AgendaModel
                cell.nameLabel!.text = model.activityName
                cell.addressLbl!.text = model.location

                cell.timeLbl.text = CommonModel.sharedInstance.getAgendaDate(dateStr: model.startActivityDate).appendingFormat(" - %@", CommonModel.sharedInstance.getAgendaDate(dateStr: model.endActivityDate))

                //Hide details screen if activity is not associated to logged in user
                if model.isAgendaActivity == false {
                    cell.accessoryType = UITableViewCellAccessoryType.none
                }
                else {
                    cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                }

               // cell.timeLbl.text =  CommonModel.sharedInstance.getAgendaDate(dateStr: model.sortDate).appendingFormat(", \(CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.startTime)) - \(CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.endTime)) - ")

//                let dateStr = CommonModel.sharedInstance.getAgendaDate(dateStr: model.sortDate).appendingFormat(", \(CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.startTime)) - \(CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.endTime)) - ")
//                cell.timeLbl.text =  dateStr.appending(model.location)
                return cell
            }
        }
        
        return cell
    }

    func configureProfileCell(cellIdentifier : String, indexPath : IndexPath) -> AttendeeDetailsCell {
        
        let cell = self.tableViewObj.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AttendeeDetailsCell
        cell.backgroundColor = cell.contentView.backgroundColor;

        cell.nameLabel?.text = personModel.name
        cell.designationLabel.text = personModel.designation


        if personModel.privacySetting == true {
            cell.imageview.sd_setImage(with: URL(string:personModel.iconUrl), placeholderImage: #imageLiteral(resourceName: "user"))
            cell.imageview?.layer.cornerRadius = cell.imageview.frame.size.height/2
            cell.imageview.clipsToBounds = true
        }
        else {
            cell.imageview.image = #imageLiteral(resourceName: "user")
        }

        //If speaker details and logged in attendee profile, hide chat and call buttons
        if isSpeakerDetails == true && self.personModel.personId == AttendeeInfo.sharedInstance.attendeeId {
        }
        else {
            UIColor().setButtonColorImageToButton(button: cell.callBtn, image:"Chat_button")
            UIColor().setButtonColorImageToButton(button: cell.messageBtn, image:"Chat_button")
            
            cell.messageBtn.layer.cornerRadius = 0
            cell.callBtn.layer.cornerRadius = 0

            //Check DND (do not disturb setting)
            if personModel.dndSetting == false {                
                cell.callBtn.isEnabled = true
                //cell.callBtn.alpha = 1
                cell.callBtn.addTarget(self, action: #selector(self.onClickOfCallBtn), for:.touchUpInside)
                
                cell.messageBtn.isEnabled = true
                // cell.messageBtn.alpha = 1
                cell.messageBtn.addTarget(self, action: #selector(self.onClickOfChatBtn), for:.touchUpInside)
            }
            else {
                cell.callBtn.isEnabled = false
                cell.messageBtn.isEnabled = false
            }
        }

        // Hide chat button if chat module is associated  in this event by admin
        if isChatPresent == false {
            //            cell.messageBtn.isHidden = true
            //            cell.messageBtn.size.width = 0
            //            cell.messageBtn.updateConstraintsIfNeeded()
            //            var frame = cell.messageBtn.frame
            //            frame.origin.x = (cell.frame.size.width - frame.size.width ) / 2
            //            cell.callBtn.frame = frame
            //            cell.callBtn.updateConstraintsIfNeeded()

            cell.messageBtn.isEnabled = false
            cell.messageBtn.alpha = 0.5
        }

        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Show session details
        if indexPath.section == 3 && self.isSpeakerDetails == true && personModel.activities.count >= 1 {
            let model = self.personModel.activities[indexPath.row] as AgendaModel

            //Hide details screen if activity is not associated to logged in user
            if model.isAgendaActivity == false {
                CommonModel.sharedInstance.showAlertWithStatus(title: Alert_Warning, message: Speaker_Session_Error, vc: self)
            }
            else {
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AgendaDetailsViewController") as! AgendaDetailsViewController
                viewController.agendaModel = self.personModel.activities[indexPath.row] as AgendaModel
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }    
}

// MARK: - Custom Cell Classes

class AttendeeDetailsCell: UITableViewCell {
    
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var imageview:UIImageView!
    @IBOutlet var designationLabel:UILabel!
    @IBOutlet var messageBtn:UIButton!
    @IBOutlet var callBtn:UIButton!
    @IBOutlet var statusLbl:UILabel!

    @IBOutlet var mobileLabel:UILabel!
    @IBOutlet var emailLabel:UILabel!
    @IBOutlet var descriptionLabel:UILabel!
    @IBOutlet var bgView: UIView!
    
}

