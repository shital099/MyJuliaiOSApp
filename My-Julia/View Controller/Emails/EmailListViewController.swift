//
//  EmailListViewController.swift
//  EventApp
//
//  Created by GCO on 7/6/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class EmailListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var listArray = [EmailModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()
        
        //        if IS_IPHONE {
        //            self.setupMenuBarButtonItems()
        //        }

        
        let refreshControl: UIRefreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action:
                #selector(EmailListViewController.handleRefresh(_:)),
                                     for: UIControlEvents.valueChanged)
            refreshControl.tintColor = UIColor.darkGray
            
            return refreshControl
        }()
        
        self.tableView.addSubview(refreshControl)

        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()
        
        //Update dyanamic height of tableview cell
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension

        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)

        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableView)

        //Fetch data from Sqlite database
        listArray = DBManager.sharedInstance.fetchEmailDataFromDB() as! [EmailModel]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UIRefreshControl Methods

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        let queue = OperationQueue()

        queue.addOperation { () -> Void in
            let urlStr = Get_AllModuleDetails_url.appendingFormat("Flag=%@",Email_List_url)

            NetworkingHelper.getRequestFromUrl(name:Email_List_url,  urlString:urlStr , callback: { response in
                //Fetch data from Sqlite database
                self.listArray = DBManager.sharedInstance.fetchEmailDataFromDB() as! [EmailModel]
            }, errorBack: { error in
            })
        }

        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIden", for: indexPath) as! EmailCustomCell
        cell.backgroundColor = cell.contentView.backgroundColor;

        var model : EmailModel
        model = listArray[indexPath.row];
        cell.nameLabel?.text = model.subject
        cell.dateLabel?.text = CommonModel.sharedInstance.getEmailDateAndTime(dateStr: model.date)

       // cell.descLabel.attributedText = self.stringFromHtml(string: model.content)
        cell.descLabel.text = ""
        
        if model.attachments.count == 0  {
            cell.attachIcon.isHidden = true
        }else {
            cell.attachIcon.isHidden = false
        }
        

//        var html2AttributedString: NSAttributedString? {
//            do {
//                return try NSAttributedString(data: Data(utf8), options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
//            } catch {
//                print("error:", error)
//                return nil
//            }
//        }
//        var html2String: String {
//            return html2AttributedString?.string ?? ""
//        }

        
//        if let htmlData = model.content.data(using: String.Encoding.unicode) {
//            do {
//                let attributedText = try NSAttributedString(data: htmlData, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
//
//                //let attributedText = try NSAttributedString(data: htmlData, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
//                cell.descLabel.attributedText = attributedText
//            } catch let e as NSError {
//                print("Couldn't translate \(model.content): \(e.localizedDescription) ")
//            }
//        }

        return cell
    }
    
    func stringFromHtml(string: String) -> NSAttributedString? {
        do {
            let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
            if let d = data {
                let str = try NSAttributedString(data: d,
                                                 options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                                                 documentAttributes: nil)
                return str
            }
        } catch {
        }
        return nil
    }

    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "EmailDetailsViewController") as! EmailDetailsViewController
        viewController.model = listArray[indexPath.row]
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Custom Cell Classes

class EmailCustomCell: UITableViewCell {
    
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var dateLabel:UILabel!
    @IBOutlet var descLabel:UILabel!
    @IBOutlet var attachIcon: UIImageView!
}


