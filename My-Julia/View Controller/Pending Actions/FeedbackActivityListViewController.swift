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

   // var dataList: NSMutableDictionary = [:]
    var sortedSections : Array<Any> = []
    var isPollList : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        if isPollList {
            self.title = "Live Poll"
        }
        else {
            self.title = "Agenda Feedback"
        }

        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()

        //Update dyanamic height of tableview cell
        self.tableView.estimatedRowHeight = 400
        self.tableView.rowHeight = UITableViewAutomaticDimension

        self.tableView.tintColor = AppTheme.sharedInstance.menuBackgroundColor.darker(by: 15)
    }

    override func viewDidAppear(_ animated: Bool) {

        CommonModel.sharedInstance.showActitvityIndicator()

        if isPollList == true {
            //Fetch all ongoing activity from db
            self.sortedSections = DBManager.sharedInstance.fetchAllPendingActionPollActivitiesFromDB(isCheckingPendingAction: false) as! Array<Any>
        }
        else {
            //Fetch all completed activity from db
            self.sortedSections = DBManager.sharedInstance.fetchAllPendingActionFeebackActivitiesFromDB(isCheckingPendingAction: false) as! Array<Any>

            //If getting data is empty from navigate to back screen
            if self.sortedSections.count == 0 {
                self.navigationController?.popViewController(animated: true)
            }
        }

        CommonModel.sharedInstance.dissmissActitvityIndicator()
        self.tableView.reloadData()
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

    // MARK: - UITableView Data Source Methods

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1 //self.sortedSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.sortedSections.count //((self.dataList.value(forKey: sortedSections[section] as! String))! as AnyObject).count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveCellIdentifier", for: indexPath) as! SessionCustomCell

        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! CustomActivityCell
        cell.bgImage?.layer.cornerRadius = 5.0
        cell.backgroundColor = cell.contentView.backgroundColor;

        cell.tag = indexPath.row

        let model = self.sortedSections[indexPath.row] as! AgendaModel //((self.dataList[sortedSections[indexPath.section]]) as! Array)[indexPath.row]

        cell.activityNameLbl.text = model.activityName
        cell.agenaNameLbl.text = model.agendaName

       // cell.timeLbl.text = String(format: "%@ - %@",CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.startTime),CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.endTime))

        cell.timeLbl.text = CommonModel.sharedInstance.getPendingActionDates(sDateStr: model.startActivityDate, eDateStr: model.endActivityDate)

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
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PollViewController") as! PollViewController
                viewController.activityId = (self.sortedSections[selectedCell.tag] as! AgendaModel).activityId
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            else {
                print("Send feedback click")
               let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ActivityFeedbackViewController") as! ActivityFeedbackViewController
                viewController.activityId = (self.sortedSections[selectedCell.tag] as! AgendaModel).activityId
                self.navigationController?.pushViewController(viewController, animated: true)
            }

        }

        return cell
    }

    // MARK: - TableView Delegate Methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if self.isPollList == true {
            print("Submit poll click")
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PollViewController") as! PollViewController
            viewController.activityId = (self.sortedSections[indexPath.row] as! AgendaModel).activityId
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else {
            print("Send feedback click")
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ActivityFeedbackViewController") as! ActivityFeedbackViewController
            viewController.activityId = (self.sortedSections[indexPath.row] as! AgendaModel).activityId
            self.navigationController?.pushViewController(viewController, animated: true)
        }

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

