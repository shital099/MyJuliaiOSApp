//
//  SpeakerDetailsViewController.swift
//  My-Julia
//
//  Created by GCO on 4/19/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class SpeakerDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableViewObj: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    
    var nameStr: String?
    var imgStr: String?
    var personModel : PersonModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Details"
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Update dyanamic height of tableview cell
        tableViewObj.estimatedRowHeight = 400
        tableViewObj.rowHeight = UITableViewAutomaticDimension
        
        //Remove extra lines from tableview
        tableViewObj.tableFooterView = UIView()
        
        //Register header cell
        tableViewObj.register(UINib(nibName: "CustomHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderCellId")
        
        //Fetch details from Sqlite database
        personModel = DBManager.sharedInstance.fetchSpeakersDetailsFromDB(speakerId: personModel.speakerId, attendeeId: self.personModel.personId)
        
        //Fetch details from server save into db
        self.getSpeakerDetailsData()
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableViewObj)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:  Button Action Methods
    
    //    func onClickOfMessageBtn() {
    //
    //    }
    //
    //    func onClickOfCallBtn() {
    //
    //    }
    
    //MARK:- WebService Methods
    
    func getSpeakerDetailsData() {
        
        NetworkingHelper.getRequestFromUrl(name:Speakers_Details_url,  urlString: Speakers_Details_url.appendingFormat(self.personModel.speakerId), callback: { response in
            print("Speakers : ",response)
            
            self.personModel = DBManager.sharedInstance.fetchSpeakersDetailsFromDB(speakerId: self.personModel.speakerId, attendeeId: self.personModel.personId)
            NSLog("self.personModel.activities.count : %d", self.personModel.activities.count)
            
            self.tableViewObj.reloadData()
        }, errorBack: { error in
            NSLog("error : %@", error)
        })
    }
    
    // MARK:-  UITableView Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if personModel.activities.count == 0 {
                return 1
            }
            else {
                return self.personModel.activities.count
            }
        }
        else if section == 2 && personModel.bioInfo == "" {
            return 0
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        //Get Idetifier
        if indexPath.section == 0 {
            return 180
        }
        else if indexPath.section == 1 {
            return 60
        }
        else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
//        else if section == 1 && personModel.activities.count == 0 {
//            return 1
//        }
        else if section == 2 && personModel.bioInfo == "" {
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
            headerView.headerLabel.text = "  SESSIONS"
        }
        else if section == 2 {
            headerView.headerLabel.text = "  BIO"
        }
        
        headerView.setGradientColor()
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PersonalInfoCell", for: indexPath) as! AttendeeDetailsCell
            cell.backgroundColor = cell.contentView.backgroundColor;

            cell.nameLabel?.text = personModel.name
            cell.imageview.layer.cornerRadius = cell.imageview.frame.size.width / 2
            cell.imageview.clipsToBounds = true
            cell.imageview.sd_setImage(with: NSURL(string:personModel.iconUrl) as URL?, placeholderImage: #imageLiteral(resourceName: "user"))
            cell.designationLabel.text = personModel.designation

            return cell
        }
        else if indexPath.section == 1 {

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
                
                let dateStr = CommonModel.sharedInstance.getAgendaDate(dateStr: model.sortDate).appendingFormat(", \(CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.startTime)) - \(CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.endTime)) - ")
                cell.timeLbl.text =  dateStr.appending(model.location)
                return cell
            }
        }
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BioInfoCell", for: indexPath) as! AttendeeDetailsCell
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear

            cell.descriptionLabel.text = personModel.bioInfo

            cell.bgView?.layer.cornerRadius = 3.0
            return cell
        }
    }
    
    // MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Show session details
        if indexPath.section == 1 {
            
            let viewController = storyboard?.instantiateViewController(withIdentifier: "AgendaDetailsViewController") as! AgendaDetailsViewController
            viewController.agendaModel = self.personModel.activities[indexPath.row]
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}
