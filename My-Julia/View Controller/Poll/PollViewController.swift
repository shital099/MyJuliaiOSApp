//
//  Poll2ViewController.swift
//  My-Julia
//
//  Created by GCO on 10/05/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class PollViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var noOfQuestionsLbl: UILabel!
    @IBOutlet weak var sucessView: UIView!
    @IBOutlet weak var tickImgBtn: UIButton!
    @IBOutlet weak var messageLbl: UILabel!

    var progressView : DDProgressView!
    var sessionModel = SessionsModel()

    var pollarray:[PollModel] = []
    var questionIndex : Int = 1
    var progressCount : Float = 0.0
    var ratingButtonTapped: ((RatingCell, AnyObject) -> Void)?
    var nextAndBackButtonTapped: ((SubmitCell, AnyObject) -> Void)?
    var submitButtonTapped: ((SubmitCell) -> Void)?

    var answerDict = NSMutableDictionary()
   // var selectedAnswerDict = NSMutableDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = true
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()

        progressView = DDProgressView()
        if IS_IPAD {
            //Remove spit view width(250) from view
            if self.splitViewController?.displayMode == UISplitViewControllerDisplayMode.primaryHidden {
                progressView.frame = CGRect(x: 40.0, y: 50.0, width: self.view.bounds.size.width - 80 , height: 0.0)
            }
            else {
                progressView.frame = CGRect(x: 40.0, y: 50.0, width: self.view.bounds.size.width - (SPLIT_WIDTH + 80) , height: 0.0)
            }
        }
        else {
            progressView.frame = CGRect(x: 40.0, y: 50.0, width: self.view.bounds.size.width - 80 , height: 0.0)
        }
            
        progressView.outerColor = AppTheme.sharedInstance.backgroundColor.getDarkerColor()
        progressView.innerColor = AppTheme.sharedInstance.backgroundColor.darker(by: 30)
        self.topView.addSubview(progressView)
        
        //Sucess view
        UIColor().setIconColorImageToButton(button: self.tickImgBtn, image:"poll-completed-fill")

        self.pollarray = DBManager.sharedInstance.fetchPollActivityQuestionsListFromDB(sessionId: self.sessionModel.sessionId, activityId: self.sessionModel.activityId) as! [PollModel]
        self.fetchUserAnswerData()

        //Fetch data from json
        self.getPollListData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- WebService Methods
    
    func getPollListData() {
        
        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()

        let urlStr = GetPoll_Question_List_url.appendingFormat("%@",self.sessionModel.activityId)
        NetworkingHelper.getRequestFromUrl(name:GetPoll_Question_List_url,  urlString:urlStr, callback: { [weak self] response in
           // print("poll questions", response)
            CommonModel.sharedInstance.dissmissActitvityIndicator()

            if response is Array<Any> {
              //  self.parsePollData(response: response)
                self?.pollarray = DBManager.sharedInstance.fetchPollActivityQuestionsListFromDB(sessionId: (self?.sessionModel.sessionId)!, activityId: (self?.sessionModel.activityId)!) as! [PollModel]
                self?.fetchUserAnswerData()

                if self?.pollarray.count == 0 {
                    self?.topView.isHidden = true
                }
                else if self?.pollarray.count == 1 {
                    self?.progressCount = 0
                }
                else {
                    self?.progressCount = 1.0 / Float((self?.pollarray.count)!)
                }
                
                self?.noOfQuestionsLbl.text = String(format:"Question %d of %d",(self?.questionIndex)!,(self?.pollarray.count)!)
                self?.progressView.progress = (self?.progressCount)!
            }
            
            if self?.pollarray.count == 0 {
                self?.messageLbl.isHidden = false
                self?.messageLbl.text = No_Poll_Question_Text
                self?.topView.isHidden = true
            }else {
                self?.messageLbl.isHidden = true
                self?.topView.isHidden = false
            }
            
        }, errorBack: { error in
            NSLog("error : %@", error)
            CommonModel.sharedInstance.dissmissActitvityIndicator()
        })
    }

    func fetchUserAnswerData()  {
        for model in pollarray {
            //Store in answer dictionary
            if model.userAnswerId != "" {
                self.answerDict.setValue(model.userAnswerId, forKey:model.id)
            }
            else {
            }
        }
        self.tableView.reloadData()
    }

    /*func parsePollData(response: AnyObject) {
        
        //let  arr = response as! NSDictionary
       // var isQuestionRemaining : Bool = false
        
        for item in response as! NSArray{
            let dict = item as! NSDictionary
            
            let model = PollModel()
            model.questionText = dict.value(forKey: "Questions") as! String
            model.id = dict.value(forKey: "Id") as! String
            model.optionsArr = dict.value(forKey: "Options") as! Array<Any>
            let qType = dict.value(forKey: "QuestionType") as! String
            model.isUserAnswered = dict.value(forKey: "IsUserAnswered") as! Bool
            model.userAnswerId = DBManager.sharedInstance.isNullString(str: dict.value(forKey: "UserAnswerId") as Any)

            //Store in answer dictionary
            if model.userAnswerId != "" {
                self.answerDict.setValue(model.userAnswerId, forKey:model.id)
            }
            else {
              //  isQuestionRemaining = true
            }
            
            if(qType == "Rating") {
                model.isRatingType = true
            }
            else {
                model.isRatingType = false
            }
            
            pollarray.append(model)
        }
        print("Server Poll array count : ",self.pollarray.count)

        tableView.reloadData()
        
//        //Hide is questions answered by user
//        if !isQuestionRemaining {
//            sucessView.isHidden = false
//        }
//        else {
//            tableView.reloadData()
//        }
    }
*/
    
    func postPollForm(selectedCell: SubmitCell) {
        
        let event = EventData.sharedInstance
        let model = pollarray[questionIndex - 1] as PollModel
        
        //If anwer is not selected
        if ((self.answerDict.value(forKey: model.id)) == nil) {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: Poll_Empty_Message, vc: self)
            return
        }
        
        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()

        var paramArray : [Any] = []
        let answerId = self.answerDict.value(forKey: model.id)
        let paramDict = ["Question": model.id,"AnswerId":answerId,"AttendeeId":AttendeeInfo.sharedInstance.attendeeId,"EventId":event.eventId]

        paramArray.append(paramDict)
    
        NetworkingHelper.postData(urlString:Post_Poll_Responce_url, param:paramArray as AnyObject, withHeader: false, isAlertShow: true, controller:self, callback: { [weak self] response in
            
            //dissmiss Indicator
            CommonModel.sharedInstance.dissmissActitvityIndicator()
            if response is NSDictionary {
                if (response.value(forKey: "responseCode") != nil) {
                  //  CommonModel.sharedInstance.showAlertWithStatus(message: Feedback_Sucess_Message, vc: self)

                    //Replace user answered status
                    model.isUserAnswered = true
                    self?.pollarray.remove(at: (self?.questionIndex)! - 1)
                    self?.pollarray.insert(model, at: (self?.questionIndex)! - 1)

                    if self?.questionIndex != self?.pollarray.count {
                        self?.changeProgressStatus(cell: selectedCell, sender: selectedCell.submitBtn)
                    }
                    else {
                        //Show sucess view
                        self?.sucessView.isHidden = false
                    }
                }
                else {
                    CommonModel.sharedInstance.showAlertWithStatus(title: "", message: Feedback_Error_Message, vc: self!)
                }
            }
        }, errorBack: { error in
        })
    }

    // MARK: - UITableView Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if pollarray.count == 0 {
            return 0
        }
        else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            let model = pollarray[questionIndex - 1] as PollModel
            if model.isRatingType == true {
                return 1
            }else {
                return model.optionsArr.count
            }
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60
        }
        else {
            return 110
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 80
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            let headerView = UITableViewHeaderFooterView()
            let label = createHeaderLabel(section)
            label.autoresizingMask = [.flexibleHeight]
            headerView.addSubview(label)
            return headerView
        }
        else {
            return nil
        }
    }
    
    func createHeaderLabel(_ section: Int)->UILabel {
        let widthPadding: CGFloat = 20.0
        let label: UILabel = UILabel(frame: CGRect(x: widthPadding, y: 0, width: self.tableView.frame.size.width - widthPadding*2, height: 0))
        let model = pollarray[questionIndex - 1] as PollModel
        label.text = model.questionText
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignment.left
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = UIFont.init(name: "Helvetica", size: 16.0)
        return label
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.clear
        header.backgroundView?.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = pollarray[questionIndex - 1] as PollModel

        if indexPath.section == 0 {
            
            if model.isRatingType == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RatingCellId", for: indexPath) as! RatingCell
                cell.backgroundColor = cell.contentView.backgroundColor;

                if (self.answerDict.value(forKey: model.id) != nil) {
                    self.showRatingStatus(cell: cell, value: self.answerDict.value(forKey: model.id) as! Int)
                }
                else {
                    self.showRateOffStatus(cell: cell)
                }

                cell.ratingButtonTapped = { [unowned self] (selectedCell, sender) -> Void in
                    let button = sender as! UIButton
                    button.accessibilityIdentifier = model.id
                    if model.isUserAnswered == false {
                        self.saveRatingValue(cell: cell, sender: sender)
                    }
                }
                
                return cell
            }
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CellId1", for: indexPath) as! Poll1CustomCell
                cell.backgroundColor = cell.contentView.backgroundColor;

                let optionDict = model.optionsArr[indexPath.row] as! NSDictionary
                cell.optionLabel.text = optionDict["OptionValue"] as? String
                cell.optionLabel.accessibilityIdentifier = optionDict["Id"] as? String
                cell.radioBtn.isSelected = false
                cell.bgView.backgroundColor = UIColor.white
                
                if model.isUserAnswered == true {
                    if model.userAnswerId == cell.optionLabel.text {
                    }
                }
                
                if self.answerDict.value(forKey: model.id) as? String == cell.optionLabel.accessibilityIdentifier {
               // if (self.answerDict.value(forKey: model.id) as? String == cell.optionLabel.text) {
                    cell.radioBtn.isSelected = true
                    cell.bgView .backgroundColor = CommonModel.RowHighlightColour
                }
                else {
                    cell.radioBtn.isSelected = false
                    cell.bgView.backgroundColor = UIColor.white
                }
                
                cell.bgView.layer.borderColor = UIColor().HexToColor(hexString: "#D7D7D7").cgColor
                cell.bgView.layer.masksToBounds = false
                cell.bgView.layer.cornerRadius = 5.0
                cell.bgView.layer.borderWidth = 1.0
                
                return cell
            }
        } //Submit button cell
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubmitCell", for: indexPath) as! SubmitCell
            cell.backgroundColor = cell.contentView.backgroundColor;
            
            //Make button theme
            cell.submitBtn.showButtonTheme()

            //Disabled submit button if user has alredy answer same question
            if model.isUserAnswered == true {
                cell.submitBtn.isEnabled = false
                cell.submitBtn.alpha = 0.6
            }
            else {
                cell.submitBtn.isEnabled = true
                cell.submitBtn.alpha = 1.0
            }

            //Hide next button if array countain only one value
            if questionIndex == pollarray.count {
                cell.nextBtn.isHidden = true
            }

            cell.nextAndBackButtonTapped = { [unowned self] (selectedCell,sender) -> Void in
                self.changeProgressStatus(cell: selectedCell, sender: sender)
            }
            
            cell.submitBtnTapped = { [unowned self] (selectedCell) -> Void in
                
                if self.answerDict.count == 0 {
                    CommonModel.sharedInstance.showAlertWithStatus(title: "", message: Poll_Empty_Message, vc: self)
                }else {
                    //Send attendee Poll answer to server and show next question
                    self.postPollForm(selectedCell: selectedCell)
                }
            }

            return cell
        }
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        if indexPath.section == 0 {
            
            let model = pollarray[questionIndex - 1] as PollModel
            
            if model.isRatingType == false {
                if model.optionsArr.count > indexPath.row {
                    if model.isRatingType == false {
                        
                        if model.isUserAnswered == false {
                            
                            let cell = tableView.cellForRow(at: indexPath) as! Poll1CustomCell
                            
                            if self.answerDict.value(forKey: model.id) as? String == cell.optionLabel.accessibilityIdentifier {
                          //  if (self.answerDict.value(forKey: model.id) as? String == cell.optionLabel.text) {
                                self.answerDict.removeObject(forKey: model.id)
                                cell.bgView.backgroundColor = UIColor.white
                                cell.radioBtn.isSelected = false
                            }
                            else {
                                self.selectAnswer(indexPath: indexPath, image: cell.bgView)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - UI And Logical Methods

    func showRateOffStatus(cell : RatingCell)  {
        
        cell.ratingBtn1.isSelected = false
        cell.ratingBtn2.isSelected = false
        cell.ratingBtn3.isSelected = false
        cell.ratingBtn4.isSelected = false
        cell.ratingBtn5.isSelected = false
    }
    
    func showRatingStatus(cell : RatingCell, value: Int)  {
        
        self.showRateOffStatus(cell: cell)
        
        for index in 1 ... value {
            
            if index == cell.ratingBtn1.tag {
                cell.ratingBtn1.isSelected = true
            }
            else if index == cell.ratingBtn2.tag {
                cell.ratingBtn2.isSelected = true
            }
            else if index == cell.ratingBtn3.tag {
                cell.ratingBtn3.isSelected = true
            }
            else if index == cell.ratingBtn4.tag {
                cell.ratingBtn4.isSelected = true
            }
            else {
                cell.ratingBtn5.isSelected = true
            }
        }
    }

    func changeProgressStatus(cell : SubmitCell, sender : AnyObject)  {
        
        //Back Question button clicked
        if cell.backBtn == sender as? UIButton {
            questionIndex -= 1
            cell.nextBtn.isHidden = false

            if questionIndex == 1 {
                cell.backBtn.isHidden = true
            }
        }
        else {
            questionIndex += 1
            cell.backBtn.isHidden = false

            if questionIndex == pollarray.count {
                cell.nextBtn.isHidden = true
            }
        }
        
        
        /*Show Progress */
        self.noOfQuestionsLbl.text = "Question \(questionIndex) of \(pollarray.count)"
        self.progressView.progress = self.progressCount * Float(questionIndex)

        if questionIndex == pollarray.count + 1 {
           sucessView.isHidden = false
        }
        else {
            tableView.reloadData()
        }
    }

    func saveRatingValue(cell : RatingCell, sender : AnyObject) {
        
        self.showRateOffStatus(cell: cell)
        
        let button = sender as! UIButton
        self.showRatingStatus(cell: cell, value: button.tag)
        
        let model = self.pollarray[self.questionIndex - 1] as PollModel
        model.answerText = String(button.tag)
        self.answerDict.setValue(button.tag, forKey: sender.accessibilityIdentifier!!)
    }

    func selectAnswer(indexPath : IndexPath, image: UIView)  {
        
        image.backgroundColor = CommonModel.RowHighlightColour
        image.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3,
                       animations: {
                        //  image.transform = CGAffineTransform.identity
                        image.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.3) {
                            image.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        }
        })
        
        let model = self.pollarray[self.questionIndex - 1] as PollModel
        let optionDict = model.optionsArr[indexPath.row] as! NSDictionary

        model.answerText = (optionDict["OptionValue"] as? String)!
        let selectedItem = optionDict["Id"] as? String
        let identifier = model.id
        self.answerDict.setValue(selectedItem, forKey:identifier)
        
        tableView.reloadData()
    }
}

// MARK: - Custom Cell Classes

class Poll1CustomCell: UITableViewCell {
    var tapped: ((Poll1CustomCell) -> Void)?
    
    @IBOutlet var optionLabel:UILabel!
    @IBOutlet var radioBtn:UIButton!
    @IBOutlet var bgImageView : UIImageView!
    @IBOutlet var bgView : UIView!
    
    @IBAction func buttonTapped(sender: AnyObject) {
        tapped?(self)
    }
}

class RatingCell: UITableViewCell {
    var ratingButtonTapped: ((RatingCell, AnyObject) -> Void)?
    
    @IBOutlet var questionLabel:UILabel!

    @IBOutlet var ratingBtn1:UIButton!
    @IBOutlet var ratingBtn2:UIButton!
    @IBOutlet var ratingBtn3:UIButton!
    @IBOutlet var ratingBtn4:UIButton!
    @IBOutlet var ratingBtn5:UIButton!
    
    @IBAction func ratingButtonTapped(sender: AnyObject) {
        ratingButtonTapped?(self, sender)
    }
}

class SubmitCell: UITableViewCell {
    
    var nextAndBackButtonTapped: ((SubmitCell, AnyObject) -> Void)?
    var submitBtnTapped: ((SubmitCell) -> Void)?

    @IBOutlet var submitBtn:DesignableButton!
    @IBOutlet var nextBtn:UIButton!
    @IBOutlet var backBtn:UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // code common to all your cells goes here
        
        //Make button theme
       // self.submitBtn.showButtonTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBAction func nextAndBackButtonTapped(sender: AnyObject) {
        nextAndBackButtonTapped?(self, sender)
    }

    @IBAction func submitBtnTapped(sender: AnyObject) {
        submitBtnTapped?(self)
    }

}

