//
//  EventDetailsVC.swift
//  My-Julia
//
//  Created by GCO on 7/12/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class EventDetailsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var coverImageView: UIImageView! //Only for image dounloading purpose

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Details"
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        tableView.tableFooterView = UIView()
        
        //Update dyanamic height of tableview cell
        tableView?.estimatedRowHeight = 1800
        tableView?.rowHeight = UITableViewAutomaticDimension

        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()
        
        //        if IS_IPHONE {
        //            self.setupMenuBarButtonItems()
        //        }
        
        self.setupImageViewWithURL(urlString: EventData.sharedInstance.eventCoverImageUrl)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupImageViewWithURL(urlString: String) {
        let url = NSURL(string: urlString)! as URL
        print("Cover URL ",urlString)
        
        //This tableHeaderView plays the placeholder role here.
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: CGFloat(CHTwitterCoverViewHeight)))
       // self.tableView.addTwitterCover(with: UIImage(named:"event_placeholder"))
        
    //    self.coverImageView.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions(rawValue: 4), completed: { (image, error, cacheType, imageURL) in
            self.coverImageView.sd_setImage(with: url, completed: { (image, error, cacheType, imageURL) in

            // Perform operation.

            if image != nil {
                //Check internet connection
                if AFNetworkReachabilityManager.shared().isReachable == true {
                    //Remove Cover image header image
                    if !(SDImageCache.shared().cachePath(forKey: urlString, inPath: urlString)?.contains(urlString))! {
                        SDImageCache.shared().removeImage(forKey: urlString, withCompletion: nil)
                    }
                }
                self.tableView.addTwitterCover(with: image)
            }
            else {
                print("Cover image donwloaded failed......")
                if let cImage = SDImageCache.shared().imageFromMemoryCache(forKey:urlString) {
                    //use image
                    self.tableView.addTwitterCover(with: cImage)
                }
            }
        })
    }


    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "EventAddressSegue" {
            let destinationVC = segue.destination as! EventAddressViewController
            destinationVC.addressStr = EventData.sharedInstance.eventVenue
            destinationVC.title = EventData.sharedInstance.eventName
        }
    }
    
    // MARK: - Navigation UIBarButtonItems
    func setupMenuBarButtonItems() {
        
        // self.navigationItem.rightBarButtonItem = self.rightMenuBarButtonItem()
        let barItem = CommonModel.sharedInstance.leftMenuBarButtonItem()
        barItem.target = self;
        barItem.action = #selector(self.leftSideMenuButtonPressed(sender:))
        self.navigationItem.leftBarButtonItem = barItem
    }
    
    // MARK: - Navigation UIBarButtonItems
    @objc func leftSideMenuButtonPressed(sender: UIBarButtonItem) {
        let masterVC : UIViewController!
        if IS_IPHONE {
            masterVC =  self.menuContainerViewController.leftMenuViewController as! MenuViewController!
        }
        else {
            masterVC = self.splitViewController?.viewControllers.first
        }
        
        if ((masterVC as? MenuViewController) != nil) {
            (masterVC as! MenuViewController).toggleLeftSplitMenuController()
        }
    }
    
    // MARK: - UITableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 2
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
//        if indexPath.row == 0 {
//            return 300
//        }
//        else {
//            return UITableViewAutomaticDimension
//        }
        return UITableViewAutomaticDimension

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsCellId", for: indexPath) as! EventDetailsCell
            cell.backgroundColor = cell.contentView.backgroundColor;

            let event = EventData.sharedInstance
            cell.eventNameLbl.text = event.eventName
            cell.eventVenueLbl.text = event.eventVenue
            
            if event.eventStartDate != "" {
                cell.eventDateLbl.text = CommonModel.sharedInstance.getEventDate(dateStr: event.eventStartDate).appendingFormat(" - %@", CommonModel.sharedInstance.getEventDate(dateStr: event.eventEndDate))
            }
            
            return cell
        }
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescCellId", for: indexPath) as! EventDetailsCell
            cell.backgroundColor = cell.contentView.backgroundColor;

            let event = EventData.sharedInstance
            cell.eventDescLbl.text = event.eventDescription
            if let htmlData = event.eventDescription.data(using: String.Encoding.unicode) {
                do {
                    let attributedText = try NSAttributedString(data: htmlData, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
                    cell.eventDescLbl.attributedText = attributedText
                } catch let e as NSError {
                    print("Couldn't translate \(event.eventDescription): \(e.localizedDescription) ")
                }
            }

            return cell
        }
    }

}

class EventDetailsCell: UITableViewCell {
    
    @IBOutlet weak var eventNameLbl: UILabel!
    @IBOutlet weak var eventDescLbl: UILabel!
    @IBOutlet weak var eventVenueLbl: UILabel!
    @IBOutlet weak var eventDateLbl: UILabel!
}

