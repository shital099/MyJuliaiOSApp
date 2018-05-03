//
//  DocumentsListViewController.swift
//  My-Julia
//
//  Created by GCO on 7/10/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class DocumentsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!

    var listArray : NSMutableArray = [] // = [DocumentModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()
        
        //        if IS_IPHONE {
        //            self.setupMenuBarButtonItems()
        //        }
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)

        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()
        
        //Update dyanamic height of tableview cell
        tableView.estimatedRowHeight = 600
        tableView.rowHeight = UITableViewAutomaticDimension

         //Fetch data from Sqlite database
        self.listArray = DBManager.sharedInstance.fetchDocumentsListFromDB().mutableCopy() as! NSMutableArray
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableView)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        //Fetch updated doc when notification receive
        self.getDocumentsListData()
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
            masterVC =  self.menuContainerViewController.leftMenuViewController as! MenuViewController?
        }
        else {
            masterVC = self.splitViewController?.viewControllers.first
        }
        
        if ((masterVC as? MenuViewController) != nil) {
            (masterVC as! MenuViewController).toggleLeftSplitMenuController()
        }
    }

    // MARK: - Webservice Methods

    func getDocumentsListData() {

        let urlStr = Get_AllModuleDetails_url.appendingFormat("Flag=%@",Documents_List_url)
        NetworkingHelper.getRequestFromUrl(name:Documents_List_url,  urlString:urlStr, callback: { response in
           // print("Documents data : ",response)
            //Fetch data from Sqlite database
            self.listArray = DBManager.sharedInstance.fetchDocumentsListFromDB().mutableCopy() as! NSMutableArray
            self.tableView.reloadData()
        }, errorBack: { error in
        })
    }

    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCustomCell", for: indexPath) as! DocumentCustomCell
        cell.backgroundColor = cell.contentView.backgroundColor;

        let model = listArray[indexPath.row] as! DocumentModel
        cell.titleLbl.text = model.title
        cell.timeLbl.text = String(format:"Valid from : %@ - %@",CommonModel.sharedInstance.getDateAndTime(dateStr: model.startDateStr),  CommonModel.sharedInstance.getDateAndTime(dateStr: model.endDateStr))

        cell.statusImageview.isHidden  = model.isRead

        if let htmlData = model.descStr.data(using: String.Encoding.unicode) {
            do {
                let attributedText = try NSAttributedString(data: htmlData, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
                cell.descLbl.attributedText = attributedText
            } catch _ as NSError {
            }
        }

        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let model = self.listArray[indexPath.row] as! DocumentModel

        //Update map read status
        DBManager.sharedInstance.updateDocumentStatus(documentId: model.docId)

        //Update notification read/unread message count in side menu bar
        let dataDict:[String: Any] = ["Order": self.view.tag, "Flag":Update_Documents_List]
        NotificationCenter.default.post(name: UpdateNotificationCount, object: nil, userInfo: dataDict)

        model.isRead = !model.isRead
        self.listArray.replaceObject(at: indexPath.row, with: model)
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)

        let viewController = storyboard?.instantiateViewController(withIdentifier: "DocumentDetailsViewController") as! DocumentDetailsViewController
        viewController.model = model
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}

// MARK: - Custom Cell Classes

class DocumentCustomCell: UITableViewCell {
    
    @IBOutlet var titleLbl:UILabel!
    @IBOutlet var imageview:UIImageView!
    @IBOutlet var descLbl:UILabel!
    @IBOutlet var timeLbl:UILabel!
    @IBOutlet var statusImageview:UIImageView!
}

