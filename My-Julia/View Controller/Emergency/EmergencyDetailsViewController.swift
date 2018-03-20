//
//  EmergencyDetailsViewController.swift
//  My-Julia
//
//  Created by GCO on 24/04/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class EmergencyDetailsViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableViewObj: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    
    var nameStr: String?
    var imgStr: String?
    var model : EmergencyModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Details"
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Update dyanamic height of tableview cell
        tableViewObj.estimatedRowHeight = 400
        tableViewObj.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        //Get Idetifier
        if indexPath.section == 0 {
            return 130
        }
        else {
           return UITableViewAutomaticDimension
        }
    }
        
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.clear
        header.backgroundView?.backgroundColor = UIColor.clear
        
        if let textlabel = header.textLabel {
            textlabel.font = textlabel.font.withSize(12)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier : String = ""
        
        //Get Idetifier
        if indexPath.section == 0 {
            cellIdentifier = "PersonalInfoCell"
        }
        else {
            cellIdentifier = "ContactInfoCell"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! EmergencyDetailCell
        cell.backgroundColor = cell.contentView.backgroundColor;

        if indexPath.section == 0
        {
            cell.titleLabel?.text = model.title
            cell.mobileLabel?.text = model.contactNo
            cell.emailLabel?.text = model.email
            cell.selectionStyle = UITableViewCellSelectionStyle.none

        }
        else{
            if model.desc == ""
            {
                cell.descLbl.isHidden = true
                cell.descriptionLabel.isHidden = true
            }
            else
            {
            cell.descriptionLabel?.text = model.desc
            }
            if model.address == ""
            {
                cell.addImg.isHidden = true
                cell.addressLabel.isHidden = true
            }
            else {
            cell.addressLabel?.text = model.address
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none

        }
        return cell
    }
}

// MARK: - Custom Cell Classes

class EmergencyDetailCell: UITableViewCell {
    
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var imageview:UIImageView!
    @IBOutlet var mobileLabel:UILabel!
    @IBOutlet var descriptionLabel:UILabel!
    @IBOutlet var addressLabel : UILabel!
    @IBOutlet var emailLabel : UILabel!
    @IBOutlet var  descLbl : UILabel!
    @IBOutlet var addImg : UIImageView!

    
}

