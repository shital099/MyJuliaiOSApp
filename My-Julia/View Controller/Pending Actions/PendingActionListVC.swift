//
//  PendingActionListVC.swift
//  My-Julia
//
//  Created by GCO on 07/06/2018.
//  Copyright © 2018 GCO. All rights reserved.
//

import UIKit

class PendingActionListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableviewObj: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!

   // var listArray : NSMutableArray = ["Update Profile", "Event Feedback","Agenda/Activity Feedback", "Submit Poll"]
    var listArray : NSMutableArray = ["Update Profile"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        //Remove extra lines from tableview
        tableviewObj.tableFooterView = UIView()

        //Check attendee pending action status and according to this add option in array
        self.checkPendingActionStatus()
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

    // MARK: - Webservice Methods

    func callUserPendingFeedbackWS() {

        NetworkingHelper.getRequestFromUrl(name:Check_Pending_Feedback_url,  urlString: Check_Pending_Feedback_url, callback: { [weak self] response in

            //Check attendee pending action status and according to this add option in array
            self?.checkPendingActionStatus()

            }, errorBack: { error in
                //Fetch updated status from database
                self.callUserPendingFeedbackWS()
        })
    }

    func checkPendingActionStatus() {

        let checkEventFeedback = DBManager.sharedInstance.checkEventFeedbackisAlreadySubmitted()
        if !checkEventFeedback {
            self.listArray.add("Event Feedback")
        }
        else {
            print("Event feedback not submitted")
        }

        //Fetch all completed activity from db
        let feedbackArray = DBManager.sharedInstance.fetchAllPendingActionFeebackActivitiesFromDB()
        if feedbackArray.count != 0 {
            self.listArray.add("Agenda/Activity Feedback")
        }

        //Fetch all ongoing activity from db
        let pollArray = DBManager.sharedInstance.fetchAllPendingActionPollActivitiesFromDB()
        if pollArray.count != 0 {
            self.listArray.add("Submit Poll")
        }

        self.tableviewObj.reloadData()
    }

    // MARK: - TableViewDataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! MenuCustomCell
        cell.backgroundColor = cell.contentView.backgroundColor;

        cell.nameLabel.text = listArray[indexPath.row] as? String

        return cell
    }

    // MARK: - UITableViewDelegate Methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let  cell = tableView.cellForRow(at: indexPath) as! MenuCustomCell
        if indexPath.row == 0 {
            let viewController = storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else {

            if cell.nameLabel.text == "Event Feedback" {
                let viewController = storyboard?.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
                viewController.isFromPendingAction = true
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            else if cell.nameLabel.text == "Agenda/Activity Feedback" {

                let viewController = storyboard?.instantiateViewController(withIdentifier: "FeedbackActivityListViewController") as! FeedbackActivityListViewController
                viewController.isPollList = false
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            else if cell.nameLabel.text == "Submit Poll" {
                let viewController = storyboard?.instantiateViewController(withIdentifier: "FeedbackActivityListViewController") as! FeedbackActivityListViewController
                viewController.isPollList = true
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }

}
