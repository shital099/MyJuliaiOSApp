//
//  SponsorDetailsViewController.swift
//  EventApp
//
//  Created by GCO on 4/20/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class SponsorDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableViewObj: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    
    var nameStr: String?
    var imgStr: String?
    var sponsorModel : Sponsors!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title =  sponsorModel.name
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Update dyanamic height of tableview cell
        tableViewObj.estimatedRowHeight = 400
        tableViewObj.rowHeight = UITableViewAutomaticDimension
        
        //Register header cell
        tableViewObj.register(UINib(nibName: "CustomHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderCellId")

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK:  UITableView Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 && sponsorModel.website == "" {
            return 0
        }
        else if section == 2 && sponsorModel.descInfo == "" {
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0{
            return 0
        }
        else if section == 1 && sponsorModel.website == "" {
            return 0
        }
        else if section == 2 && sponsorModel.descInfo == "" {
            return 0
        }
        return 23
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderCellId") as! CustomHeaderView
        
        headerView.backgroundColor = AppTheme.sharedInstance.menuBackgroundColor.darker(by: 15)
        
        if section == 0 {
            headerView.headerLabel.text = ""
        }
        else if section == 1 {
            headerView.headerLabel.text = "  WEBSITE"
        }
        else {
            headerView.headerLabel.text = "  DESCRIPTION"
        }
        
        headerView.setGradientColor()
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        //Get Idetifier
        if indexPath.section == 0 {
            return 170
        }
        else if indexPath.section == 1 {
            return 50
        }
        else {
            return UITableViewAutomaticDimension
        }
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier : String = ""
        
        //Get Idetifier
        if indexPath.section == 0 {
            cellIdentifier = "PersonalInfoCell"
        }
        else if indexPath.section == 1 {
            cellIdentifier = "BioInfoCell"
        }
        else {
            cellIdentifier = "WebsiteInfoCell"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SponsorDetailsCell
        cell.backgroundColor = cell.contentView.backgroundColor;

        if indexPath.section == 0
        {
            cell.nameLabel?.text = sponsorModel.name
            cell.imageview.sd_setImage(with: NSURL(string:sponsorModel.iconUrl) as URL?, placeholderImage: nil)
            cell.selectionStyle = UITableViewCellSelectionStyle.none

            
        }
        else if  indexPath.section == 1{
            cell.website.text = sponsorModel.website
            cell.selectionStyle = UITableViewCellSelectionStyle.none

            cell.bgView?.layer.cornerRadius = 3.0
        }
        else {
            cell.descriptionLabel.text = sponsorModel.descInfo
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.bgView?.layer.cornerRadius = 3.0
        }
        return cell
    }
    
}
class SponsorDetailsCell: UITableViewCell {
    
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var imageview:UIImageView!
    @IBOutlet var website:UILabel!
    
    @IBOutlet var mobileLabel:UILabel!
    @IBOutlet var emailLabel:UILabel!
    @IBOutlet var descriptionLabel:UILabel!
    @IBOutlet var bgView: UIView!
    
}

