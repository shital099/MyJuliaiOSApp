//
//  BadgeViewController.swift
//  My-Julia
//
//  Created by GCO on 28/11/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class BadgeViewController: UIViewController {

    @IBOutlet weak var bgImageView: UIImageView!

    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var attendeeNameLbl: UILabel!
    @IBOutlet weak var eventNameLbl: UILabel!
    @IBOutlet weak var eventDateLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()

        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)

        self.attendeeNameLbl.text = AttendeeInfo.sharedInstance.attendeeName
        
        let event = EventData.sharedInstance
        self.eventNameLbl.text = event.eventName
        self.eventNameLbl.text = event.eventVenue
        
        if event.eventStartDate != "" {
            self.eventDateLbl.text = CommonModel.sharedInstance.getEventDate(dateStr: event.eventStartDate).appendingFormat(" - %@", CommonModel.sharedInstance.getEventDate(dateStr: event.eventEndDate))
        }

        if !AttendeeInfo.sharedInstance.qr_code.isEmpty {
            qrImageView.sd_setImage(with: URL(string:AttendeeInfo.sharedInstance.qr_code), placeholderImage: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Navigation UIBarButtonItems
    
    func setupMenuBarButtonItems() {
        // self.navigationItem.rightBarButtonItem = self.rightMenuBarButtonItem()
        let barItem = CommonModel.sharedInstance.leftMenuBarButtonItem()
        barItem.target = self;
        barItem.action = #selector(self.leftSideMenuButtonPressed(sender:))
        self.navigationItem.leftBarButtonItem = barItem
    }
    
    @objc func leftSideMenuButtonPressed(sender: UIBarButtonItem) {
        let masterVC : UIViewController!
        if IS_IPHONE {
            masterVC =  self.menuContainerViewController.leftMenuViewController as! MenuViewController?
        }
        else {
            masterVC = self.splitViewController?.viewControllers.first
        }
        
        if ((masterVC as? MenuViewController) != nil) {
            (masterVC as! MenuViewController).toggleLeftSplitMenuController()
        }
    }
}
