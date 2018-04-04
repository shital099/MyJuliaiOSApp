//
//  ActivityQuestionsListViewController.swift
//  My-Julia
//
//  Created by gco on 30/01/18.
//  Copyright © 2018 GCO. All rights reserved.
//

import UIKit

class ActivityQuestionsListViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    var statusAlert : UIAlertController!
    var indexPath : NSIndexPath! = nil
//    var listArray:NSMutableArray = []
    var model = AgendaModel()
    var questionModel = PollModel()
    var ansDict = NSMutableDictionary()
    var tablecell : QuestionCell! = nil
    var alert : TKAlert!
    var listArray : [PollModel] = []

   override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup delegates */
        tableView.delegate = self
        tableView.dataSource = self
        
        self.title = "Activity Questions"
        
        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()
        
        //Update dyanamic height of tableview cell
        self.tableView.estimatedRowHeight = 400
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableView)
        
       //Fetch data from Sqlite database
        //        listArray = DBManager.sharedInstance.saveSpeakerActivitiesIntoDB(response: AnyObject as AnyObject)
        
        //Fetch data from Sqlite database
       // self.fetchLatestPollQuestionList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.listArray.count != 0 {
            self.listArray.removeAll()
        }
//        //Show Indicator
//        CommonModel.sharedInstance.showActitvityIndicator()
        self.listArray = DBManager.sharedInstance.fetchSpeakerPollQuestions(activityId: self.model.activityId) as! [PollModel]
        self.tableView.reloadData()

        //Fetch data from Sqlite database
        self.fetchLatestPollQuestionList()
    }
    

    // MARK: - UITableView Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cellidentifier", for: indexPath) as! ActListCell
        cell.backgroundColor = cell.contentView.backgroundColor
        cell.bgImage?.layer.cornerRadius = 5.0
        let questionModel = listArray[indexPath.row]
        cell.actnameLbl.text = questionModel.questionText
//        cell.opt1lbl.text = questionModel.opt1
//        cell.opt2lbl.text = questionModel.opt2
//        cell.opt3lbl.text = questionModel.opt3
//        cell.opt4lbl.text = questionModel.opt4

//        cell.editPollBtn.tag = indexPath.row
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
//        let index = sender.tag
        let viewController = storyboard?.instantiateViewController(withIdentifier: "AddPollQuestionsViewController") as! AddPollQuestionsViewController
        viewController.questionModel = self.listArray[indexPath.row]
        viewController.activityId = model.activityId
        viewController.isAddPoll = false
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - API fetch and Parse methods
    
    func fetchLatestPollQuestionList() {
        let paramDict = ["EventId":EventData.sharedInstance.eventId, "AttendeeId" : AttendeeInfo.sharedInstance.attendeeId,"ActivityId": model.activityId]
//        print(" fetch latest poll Parameter list", paramDict)
        NetworkingHelper.postData(urlString: Get_Speaker_latest_Poll, param:paramDict as AnyObject, withHeader: true, isAlertShow: false, controller:self, callback:
            { response in
           // print("activities Questions list", response)
            if response is Array<Any> {
//            self.parseActivityData(response: response)
                self.listArray = DBManager.sharedInstance.fetchSpeakerPollQuestions(activityId: self.model.activityId) as! [PollModel]
                self.tableView.reloadData()
            }
        }, errorBack: { error in
            print("error",error)
        })
    }
    
    
//    func parseActivityData(response : AnyObject)
//    {
//        for item in response as! NSArray{
//            let dict = item as! NSDictionary
//            let questionModel = PollModel()
//
//            questionModel.questionText = dict.value(forKey: "Questions") as! String!
//            questionModel.questionsId = dict.value(forKey: "Id") as! String!
////            questionModel.optionsArr = (dict.value(forKey: "Options") as! NSArray) as! Array<Any>
//
//            // new try
//            questionModel.opt1 = dict.value(forKey: "Option1") as! String!
//            questionModel.opt2 = dict.value(forKey: "Option2") as! String!
//            questionModel.opt3 = dict.value(forKey: "Option3") as! String!
//            questionModel.opt4 = dict.value(forKey: "Option4") as! String!
//            questionModel.op1Id = dict.value(forKey: "Option1Id") as! String!
//            questionModel.opt2Id = dict.value(forKey: "Option2Id") as! String!
//            questionModel.opt3Id = dict.value(forKey: "Option3Id") as! String!
//            questionModel.opt4Id = dict.value(forKey: "Option4Id") as! String!
//
//            //            let optionDict = model.optionsArray[indexPath.row] as! NSDictionary
//            //            model.opt1 = optionDict["OptionValue"] as! String
//            //            ansDict.setValue(optionDict["Id"], forKey: model.quesId)
//            //            print("Ans Dict - ", self.ansDict)
//
//            self.listArray.add(questionModel)
//        }
//        self.tableView.reloadData()
//    }
    
    // MARK: - Button Action Methods
    
    @IBAction func addPollQuestion(_ sender: UIBarButtonItem) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "AddPollQuestionsViewController") as! AddPollQuestionsViewController
        viewController.activityId = model.activityId
        viewController.isAddPoll = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }

//    @IBAction func editPollQuest(_ sender: UIButton) {
////        isUpdate = true
//        let index = sender.tag
//        let viewController = storyboard?.instantiateViewController(withIdentifier: "AddPollQuestionsViewController") as! AddPollQuestionsViewController
//        viewController.questionModel = self.listArray[index] as! PollModel
//        viewController.activityId = model.activityId
//        isAddPoll = false
//        self.navigationController?.pushViewController(viewController, animated: true)
//
//        //        self.updatePollQuestion(index : index)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
}

// MARK: - Custom Cell Classes
class ActListCell: UITableViewCell {
    
    @IBOutlet weak var actnameLbl: UILabel!
    @IBOutlet weak var opt1lbl : UILabel!
    @IBOutlet weak var opt2lbl : UILabel!
    @IBOutlet weak var opt3lbl : UILabel!
    @IBOutlet weak var opt4lbl : UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var editPollBtn : UIButton!
    
}
