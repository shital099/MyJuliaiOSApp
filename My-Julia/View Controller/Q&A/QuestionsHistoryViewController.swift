//
//  QuestionsHistoryViewController.swift
//  EventApp
//
//  Created by GCO on 8/24/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class QuestionsHistoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var totalCountLbl: UILabel!
    @IBOutlet weak var sessionNameLbl: UILabel!
    @IBOutlet weak var speakerNameLbl: UILabel!
    @IBOutlet weak var queInputView: UIView!
    @IBOutlet weak var queTextView: UITextView!
    
    var alert : TKAlert!
    var placeholderLabel : UILabel!
    var timer: Timer!
    var sessionModel = SessionsModel()

    // var listArray = [Questions]()
    var listArray:NSMutableArray = []
    
    var likeButtonTapped: ((QuestionsCustomCell, AnyObject) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableView)
        
        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()
        
        //Update dyanamic height of tableview cell
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        
        ///Fetch Questions data from json
        self.fetchActivityQuestionList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
    
       
    // MARK: - Webservice Methods
    func fetchActivityQuestionList() {
        
        let urlStr = GetQuestions_List_url.appendingFormat("%@",self.sessionModel.activityId, self.sessionModel.activitySessionId )
        NetworkingHelper.getRequestFromUrl(name:GetQuestions_List_url,  urlString:urlStr, callback: { response in
            print("Questions :", response)
            if response is Array<Any> {
                self.parseQuestionsData(response: response)
            }
        }, errorBack: { error in
            NSLog("error : %@", error)
        })
    }
    
    func parseQuestionsData(response: AnyObject) {
        
        if listArray.count != 0 {
            listArray.removeAllObjects()
        }
        
        for item in response as! NSArray{
            let  dict = item as! NSDictionary
            
            let model = Questions()
            model.queId = dict.value(forKey: "Id") as! String!
            model.queStr = dict.value(forKey: "Question") as! String!
            model.queCount = dict.value(forKey: "Count") as! Int
            model.isUserLike = dict.value(forKey: "isUserLike") as! Bool
            model.timeStr = dict.value(forKey: "CreatedDate") as! String
            model.activityId = dict.value(forKey: "ActivityId") as! String!
            model.userId = dict.value(forKey: "CreatedBy") as! String!
            model.userNameStr = dict.value(forKey: "Name") as! String!
            
            self.listArray.add(model)
        }
        
        self.totalCountLbl.text = String(format: "%d QUESTIONS", listArray.count)
        self.tableView.reloadData()
    }
    
    
    // MARK: - Button Action Methods
    
    @IBAction func emailButtonTapped(sender: AnyObject) {
        
        //Show input text alert view
    }
    
    
    // MARK: - UITableView Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! QuestionsCustomCell
        cell.backgroundColor = cell.contentView.backgroundColor;

        let model = listArray[indexPath.row] as! Questions
        cell.questionLbl.text = model.queStr
        cell.queCountLbl.text = String(format: "%d", model.queCount)
        cell.userNameLbl.text = model.userNameStr
        cell.timeLbl.text = CommonModel.sharedInstance.getQuestionTime(dateStr: model.timeStr)
        
        //Show like button status
        cell.likeButton.isSelected = model.isUserLike
        return cell
    }
}
