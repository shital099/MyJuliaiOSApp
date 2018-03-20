//
//  WiFiDetailsViewController.swift
//  EventApp
//
//  Created by GCO on 24/04/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class WiFiDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableViewObj: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    
    var nameStr: String?
    var imgStr: String?
    var wifiModel : WiFiModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = wifiModel.name
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Update dyanamic height of tableview cell
        tableViewObj.estimatedRowHeight = 500
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
        //Get Identifier
        if indexPath.section == 0 {
            return 250
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
            cellIdentifier = "BioInfoCell"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WiFiDetailCell
        cell.backgroundColor = cell.contentView.backgroundColor;

        if indexPath.section == 0
        {
            cell.name?.text = wifiModel.name
//            cell.imageview.layer.cornerRadius = cell.imageview.frame.size.width / 2
//            cell.imageview.clipsToBounds = true
//            let path = BASE_URL.appending(wifiModel.iconUrl)
//            cell.imageview.sd_setImage(with: NSURL(string:path) as URL?, placeholderImage: #imageLiteral(resourceName: "WiFi"))
            cell.selectionStyle = UITableViewCellSelectionStyle.none

        }
        else {
            cell.network?.text = wifiModel.network
            cell.password?.text = wifiModel.password
            cell.notelbl?.text = wifiModel.note
            cell.bgView?.layer.cornerRadius = 3.0
            cell.selectionStyle = UITableViewCellSelectionStyle.none

        }
        return cell
    }
}

// MARK: - Custom Cell Classes

class WiFiDetailCell: UITableViewCell {
    
    @IBOutlet var name:UILabel!
    @IBOutlet var network:UILabel!
    @IBOutlet var password:UILabel!
    @IBOutlet var bgView: UIView!
    @IBOutlet var imageview:UIImageView!
    @IBOutlet var notelbl : UILabel!

}

