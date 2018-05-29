//
//  PollSessionListViewController.swift
//  My-Julia
//
//  Created by GCO on 8/24/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class PollSessionListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var addPollbtn : UIButton!

    //var listArray:NSMutableArray = []
    var dataList: NSMutableDictionary = [:]
    var sortedSections : Array<Any> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()
        
        //        if IS_IPHONE {
        //            self.setupMenuBarButtonItems()
        //        }

        //Update dyanamic height of tableview cell
        self.tableView.estimatedRowHeight = 400
        self.tableView.rowHeight = UITableViewAutomaticDimension

        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)

        //Change ask question button color according to background color
        self.addPollbtn.backgroundColor = AppTheme.sharedInstance.backgroundColor.darker(by: 40)!

        //Set separator color according to background color
      //  CommonModel.sharedInstance.applyTableSeperatorColor(object: tableView)
        
        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()
        
        self.sortData(dataArray: DBManager.sharedInstance.fetchPollActivitiesDataFromDB())
        
       // if listArray.count == 0 {
            //Show Indicator
            CommonModel.sharedInstance.showActitvityIndicator()
       // }

        ///Fetch Questions data from json
        self.fetchAllCompletedPollSessionList()
        
        //Register header cell
        tableView.register(UINib(nibName: "CustomHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderCellId")

        // MARK: - isSpeaker
        if(AttendeeInfo.sharedInstance.isSpeaker == true){

            self.addPollbtn.isHidden = false
        }

        else{
            self.addPollbtn.isHidden = true
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

    // MARK: - Button Action Methods

    @IBAction func addPollBtnClick(_ sender: Any) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "SpeakerActivityListViewController") as! SpeakerActivityListViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func fetchCurrentSession() {
        
        let array = DBManager.sharedInstance.fetchCurrentActivity()
        
        for item in array  {
            let model = item as! SessionsModel

            if model.sortActivityDate != nil {
                
                let dateStr = CommonModel.sharedInstance.getListHeaderDate(dateStr: model.sortActivityDate)
                if (dataList.value(forKey: dateStr) != nil) {
                    let array = dataList.value(forKey: dateStr) as! NSMutableArray
                    array.add(model)
                    dataList.setValue(array, forKey: dateStr)
                }
                else {
                    let array = NSMutableArray()
                    array.add(model)
                    dataList.setValue(array, forKey: dateStr)
                    sortedSections.append(dateStr)
                }
            }
        }
    }
    
    // MARK: - Webservice Methods
    func fetchAllCompletedPollSessionList() {
        
        let urlStr = Get_AllModuleDetails_url.appendingFormat("Flag=%@",GetPollActivities__url)
        CommonModel.sharedInstance.dissmissActitvityIndicator()
        NetworkingHelper.getRequestFromUrl(name:GetPollActivities__url,  urlString:urlStr, callback: { [weak self] response in

            self?.sortData(dataArray: DBManager.sharedInstance.fetchPollActivitiesDataFromDB())
        }, errorBack: { error in
            CommonModel.sharedInstance.dissmissActitvityIndicator()
        })
    }

    func sortData(dataArray : NSArray)  {
        
        //Clear previous data
        if sortedSections.count != 0 {
            sortedSections.removeAll()
        }
        if dataList.count != 0 {
            dataList.removeAllObjects()
        }
        
        //Check currently activity session going on
        self.fetchCurrentSession()
        
        for item in dataArray  {
            
            let model = item as! SessionsModel
            let dateStr = CommonModel.sharedInstance.getListHeaderDate(dateStr: model.sortActivityDate)
            if (dataList.value(forKey: dateStr) != nil) {
                let array = dataList.value(forKey: dateStr) as! NSMutableArray
                array.add(item)
                dataList.setValue(array, forKey: dateStr)
            }
            else {
                let array = NSMutableArray()
                array.add(item)
                dataList.setValue(array, forKey: dateStr)
                sortedSections.append(dateStr)
            }
        }
        
        tableView.reloadData()
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

    // MARK: - UITableView Data Source Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.sortedSections.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ((self.dataList.value(forKey: sortedSections[section] as! String))! as AnyObject).count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderCellId") as! CustomHeaderView
        
        headerView.backgroundColor = AppTheme.sharedInstance.menuBackgroundColor.darker(by: 15)
        
        headerView.headerLabel.text = self.sortedSections[section] as? String
        headerView.headerLabel.font = headerView.headerLabel.font.withSize(14)
        
        headerView.setGradientColor()
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       // let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveCellIdentifier", for: indexPath) as! SessionCustomCell

        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! SessionCustomCell
        cell.backgroundColor = cell.contentView.backgroundColor
        cell.bgImage?.layer.cornerRadius = 5.0

        let model : SessionsModel = ((self.dataList[sortedSections[indexPath.section]]) as! Array)[indexPath.row]

        cell.activityNameLbl.text = model.activityName
        cell.agenaNameLbl.text = model.agendaName
        cell.timeLbl.text = String(format: "%@ - %@",CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.startTime),CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.endTime))

        cell.locationLbl.text = model.location

        if model.isActive {

            cell.statusImage.isHighlighted = true
            cell.timeLbl.textColor = UIColor(red: Int(20.0/255.0), green: Int(109.0/255.0), blue: Int(45.0/255.0))
        }
        else {
            cell.statusImage.isHighlighted = false
            cell.timeLbl.textColor = UIColor(red: Int(20.0/255.0), green: Int(109.0/255.0), blue: Int(45.0/255.0))
        }
        
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model : SessionsModel = ((self.dataList[sortedSections[indexPath.section]]) as! Array)[indexPath.row]
        if model.isActive {
            
            let viewController = storyboard?.instantiateViewController(withIdentifier: "PollViewController") as! PollViewController
            viewController.sessionModel = ((self.dataList[sortedSections[indexPath.section]]) as! Array)[indexPath.row]
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else {
        
            let viewController = storyboard?.instantiateViewController(withIdentifier: "PollHistoryViewController") as! PollHistoryViewController
            viewController.sessionModel = ((self.dataList[sortedSections[indexPath.section]]) as! Array)[indexPath.row]
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

