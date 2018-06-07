//
//  FeedbackActivityListViewController.swift
//  My-Julia
//
//  Created by GCO on 07/06/2018.
//  Copyright © 2018 GCO. All rights reserved.
//

import UIKit

class FeedbackActivityListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!

    var dataList: NSMutableDictionary = [:]
    var sortedSections : Array<Any> = []
    var isPollList : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()

        //Update dyanamic height of tableview cell
        self.tableView.estimatedRowHeight = 400
        self.tableView.rowHeight = UITableViewAutomaticDimension

        //Register header cell
        tableView.register(UINib(nibName: "CustomHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderCellId")

        self.tableView.tintColor = AppTheme.sharedInstance.menuBackgroundColor.darker(by: 15)

        if isPollList == true {
            //Fetch all ongoing activity from db
            self.sortData(dataArray: DBManager.sharedInstance.fetchAllPendingActionPollActivitiesFromDB())
        }
        else {
            //Fetch all completed activity from db
            self.sortData(dataArray: DBManager.sharedInstance.fetchAllPendingActionFeebackActivitiesFromDB())
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

    func sortData(dataArray : NSArray)  {

        //Clear previous data
        if sortedSections.count != 0 {
            sortedSections.removeAll()
        }
        if dataList.count != 0 {
            dataList.removeAllObjects()
        }

        for item in dataArray  {

            let model = item as! AgendaModel
            let dateStr = CommonModel.sharedInstance.getListHeaderDate(dateStr: model.sortDate)
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

        print(" Data Array : ",dataArray.count)
        tableView.reloadData()
    }

    // MARK: - UITableView Data Source Methods

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.sortedSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ((self.dataList.value(forKey: sortedSections[section] as! String))! as AnyObject).count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderCellId") as! CustomHeaderView
        // headerView.backgroundColor = AppTheme.sharedInstance.menuBackgroundColor.darker(by: 15)

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

        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! CustomActivityCell
        cell.bgImage?.layer.cornerRadius = 5.0
        cell.backgroundColor = cell.contentView.backgroundColor;

        let model : AgendaModel = ((self.dataList[sortedSections[indexPath.section]]) as! Array)[indexPath.row]

        cell.activityNameLbl.text = model.activityName
        cell.agenaNameLbl.text = model.agendaName

        cell.timeLbl.text = String(format: "%@ - %@",CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.startTime),CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.endTime))

        cell.locationLbl.text = model.location

        if isPollList == true {
            cell.button.setTitle("Submit poll", for: .normal)
        }
        else {
            cell.button.setTitle("Send feedback", for: .normal)
        }

        //Add button action
        cell.sendButtonTapped = { [unowned self] (selectedCell, sender) -> Void in

            if self.isPollList == true {
                print("Submit poll click")
            }
            else {
                print("Send feedback click")
            }
        }

        return cell
    }

    // MARK: - TableView Delegate Methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let viewController = storyboard?.instantiateViewController(withIdentifier: "ActivityFeedbackViewController") as! ActivityFeedbackViewController
        viewController.activityId = "" //(((self.dataList[sortedSections[indexPath.section]]) as! Array)[indexPath.row] as? AgendaModel)!.activityId as! String
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Custom Cell Classes

class CustomActivityCell: UITableViewCell {

    @IBOutlet weak var activityNameLbl:UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var agenaNameLbl:UILabel!

    @IBOutlet weak var button:UIButton!

    var sendButtonTapped: ((CustomActivityCell, AnyObject) -> Void)?

    @IBAction func optionButtonTapped(sender: AnyObject) {
        sendButtonTapped?(self, sender)
    }

}

