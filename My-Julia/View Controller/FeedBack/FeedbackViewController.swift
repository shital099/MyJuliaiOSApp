//
//  FeedbackViewController.swift
//  My-Julia
//
//  Created by GCO on 10/05/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var sendBtn: DesignableButton!
    @IBOutlet weak var sucessView: UIView!
    @IBOutlet weak var tickImgBtn: UIButton!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var reSendBtn: UIButton!
    @IBOutlet weak var submittedMessageLbl: UILabel!
    @IBOutlet weak var topView: UIView!

    var ansDict = NSMutableDictionary()
    var feedbackarray:[FeedbackModel] = []
    var editingIndexPath : NSIndexPath! = nil
    var isFromPendingAction : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        //If feedback open from pending action, dont show side menu icon
        if !isFromPendingAction {

            //Show menu icon in ipad and iphone
            self.setupMenuBarButtonItems()
        }

        //Update dyanamic height of tableview cell
        self.tableView.estimatedRowHeight = 400
        self.tableView.rowHeight = UITableViewAutomaticDimension

        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Make button theme
        sendBtn.showButtonTheme()

        self.sendBtn.isHidden = true
        self.submittedMessageLbl.isHidden = true

        //Check internet connection
        if AFNetworkReachabilityManager.shared().isReachable == true {
            //Check User has already submitted feedback
            self.checkUserFeedback()
        }
        else {
            //Check event feedback
            let checkEventFeedback = DBManager.sharedInstance.checkEventFeedbackisAlreadySubmitted(activityId: EventData.sharedInstance.eventId)
            if !checkEventFeedback {
                //Fetch data from Sqlite database
                self.feedbackarray = DBManager.sharedInstance.fetchFeedbackDataFromDB() as! [FeedbackModel]
                //Hide send button if no questions added in list
                if self.feedbackarray.count != 0 {
                    self.sendBtn.isHidden = false
                }
            }
            else {
                self.submittedMessageLbl.text = Activity_Feedback_submitted
                self.topView.isHidden = true
                self.submittedMessageLbl.isHidden = false
            }
        }

        //Sucess view
        UIColor().setIconColorImageToButton(button: self.tickImgBtn, image:"poll-completed-fill")

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FeedbackViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardChange), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardChange), name: .UIKeyboardWillHide, object: nil)
    }

    @objc func hideKeyboard() {
        tableView.endEditing(true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(keyboardChange)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Keyboard NSNotification Methods

    @objc func keyboardChange(notification: NSNotification) {
        
        let userInfo : NSDictionary = notification.userInfo! as NSDictionary
        var keyboardEndFrame : CGRect
        
        if let tmp = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            keyboardEndFrame = tmp.cgRectValue
        }
        
        keyboardEndFrame = ((userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue)!
        
        var contentInsets:UIEdgeInsets
        if notification.name == NSNotification.Name.UIKeyboardWillShow {
            
            if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
                
                contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardEndFrame.height, 0.0);
            }
            else {
                contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardEndFrame.width, 0.0);
                
            }
            
            tableView.contentInset = contentInsets
            print("editingIndexPath : ",editingIndexPath)
            if editingIndexPath != nil {
                tableView.scrollToRow(at: editingIndexPath as IndexPath, at: .top, animated: true)
            }
            tableView.scrollIndicatorInsets = tableView.contentInset
        }
        else{
            contentInsets = UIEdgeInsets.zero
            self.tableView.contentInset = contentInsets
            tableView.scrollIndicatorInsets = tableView.contentInset
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
    
    @objc func leftSideMenuButtonPressed(sender: UIBarButtonItem) {
        let masterVC : UIViewController!
        if IS_IPHONE {
            masterVC =  self.menuContainerViewController.leftMenuViewController as! MenuViewController
        }
        else {
            masterVC = self.splitViewController?.viewControllers.first
        }
        
        if ((masterVC as? MenuViewController) != nil) {
            (masterVC as! MenuViewController).toggleLeftSplitMenuController()
        }
    }
    
    // MARK: - Button Action Methods
    
    @IBAction func sendBtnClick(sender:Any) {
        
        //Send attendee feedback to server
        self.postFeedbackForm()
    }
    
    // MARK: - Webservice Methods

    func checkUserFeedback() {

        NetworkingHelper.getRequestFromUrl(name:Check_User_Feedback_url,  urlString: Check_User_Feedback_url, callback: { [weak self] response in

            if response is NSDictionary {
                if response.value(forKey: "responseCode") as! Bool == true {
                    self?.submittedMessageLbl.text = Activity_Feedback_submitted
                    self?.topView.isHidden = true
                    self?.submittedMessageLbl.isHidden = false

                    //Save feedback is given to this event
                    DBManager.sharedInstance.saveFeedbackGivenToEventDataIntoDB(activityId: EventData.sharedInstance.eventId)
                }
                else {
//                    NotificationCenter.default.addObserver(self, selector: #selector(self?.keyboardChange), name: .UIKeyboardWillShow, object: nil)
//                    NotificationCenter.default.addObserver(self, selector: #selector(self?.keyboardChange), name: .UIKeyboardWillHide, object: nil)

                    //Fetch data from Sqlite database
                    self?.feedbackarray = DBManager.sharedInstance.fetchFeedbackDataFromDB() as! [FeedbackModel]

                    //Hide send button if no questions added in list
                    if self?.feedbackarray.count == 0 {
                        self?.sendBtn.isHidden = true
                    }
                    else {
                        self?.sendBtn.isHidden = false
                        self?.tableView.reloadData()
                    }
                }
            }
        }, errorBack: { error in
        })
    }

    func postFeedbackForm() {
        
        if self.ansDict.count == 0 {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: Feedback_Empty_Message, vc: self)
            return
        }
        
        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()
        let event = EventData.sharedInstance
        var paramArr : [Any] = []
        let keys = self.ansDict.allKeys
        
        for index in 0 ... keys.count - 1 {
            let paramDict = ["QuestionId": keys[index] ,"Answer":self.ansDict.value(forKey: keys[index] as! String) ?? "","AttendeeId":AttendeeInfo.sharedInstance.attendeeId, "EventId":event.eventId]
            paramArr.append(paramDict)
        }
        
        NetworkingHelper.postData(urlString:Post_Feedback_Responce_url, param:paramArr as AnyObject, withHeader: false, isAlertShow: true, controller:self, callback: { [weak self] response in
            //dissmiss Indicator
            CommonModel.sharedInstance.dissmissActitvityIndicator()
            
            if response is NSDictionary {
                
                if (response.value(forKey: "responseCode") != nil) {
                    self?.showStatusView(isSucess: true)
                    //Save feedback is given to this event
                    DBManager.sharedInstance.saveFeedbackGivenToEventDataIntoDB(activityId: EventData.sharedInstance.eventId)
                }
                else {
                    self?.showStatusView(isSucess: false)
                    //Save feedback is given to this event
                   // DBManager.sharedInstance.saveFeedbackGivenToEventDataIntoDB(activityId: EventData.sharedInstance.eventId)
                }
            }
        }, errorBack: { error in
        })
    }


    func showStatusView(isSucess : Bool) {
        self.sucessView.isHidden = false

        if isSucess {
            self.messageLbl.text = Feedback_Sucess_Message
            UIColor().setIconColorImageToButton(button: self.tickImgBtn, image:"poll-completed-fill")
            self.reSendBtn.isHidden = true
        }
        else {
            self.messageLbl.text = Feedback_Error_Message
            UIColor().setIconColorImageToButton(button: self.tickImgBtn, image:"feeback-error")
            self.reSendBtn.isHidden = false
        }
    }
    
    // MARK: - UITextView Delegate Methods
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        let cell = textView.superview?.superview as! UITableViewCell
        let indexPath = self.tableView.indexPath(for: cell)
        self.tableView.scrollToRow(at: indexPath!, at: .top, animated: true)
        self.editingIndexPath = indexPath! as NSIndexPath
        
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let result = (textView.text as NSString?)?.replacingCharacters(in: range, with: text)
        ansDict.setValue(result, forKey: textView.accessibilityIdentifier!)

        print("test character length : ",textView.text.count)

        //Retrict feedback text length
        if(textView.text.count > 498 && range.length == 0) {
            return false
        }

        return true
    }
    
    // MARK: - UITableView Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return feedbackarray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        let model = feedbackarray[section] as FeedbackModel
//        if model.questionType == "Multiple" {
//            return model.optionsArr.count;
//        }
//        else {
            return 1
     //   }
    }
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?  {
    //        let model = feedbackarray[section] as FeedbackModel
    //        return model.questionText
    //    }
    
   /* func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        let label = createHeaderLabel(section)
        label.autoresizingMask = [.flexibleHeight]
        headerView.addSubview(label)
        return headerView
    }
    
    func createHeaderLabel(_ section: Int)->UILabel {
        let widthPadding: CGFloat = 15.0
        let label: UILabel = UILabel(frame: CGRect(x: widthPadding, y: 0, width: self.tableView.frame.size.width - widthPadding*2, height: 0))
        let model = feedbackarray[section] as FeedbackModel
        label.text = model.questionText
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignment.left
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = UIFont.init(name: "Helvetica-Medium", size: 16.0)
        //label.sizeToFit()
        //label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline) //use your own font here - this font is for accessibility
        return label
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.backgroundView?.backgroundColor =  AppTheme.sharedInstance.backgroundColor
    }
    */
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       // let model = feedbackarray[indexPath.section] as FeedbackModel
        
//        if model.questionType == "Rating" {
//            return 65
//        }
//        else if model.questionType == "Multiple" {
//            return 190
//        }
//        else { //Multiple
//            return 160
//        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = feedbackarray[indexPath.section] as FeedbackModel
        
        if model.questionType == "Multiple" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackMultipleCell", for: indexPath) as! FeedbackMultipleCell
            cell.backgroundColor = cell.contentView.backgroundColor;
            cell.questionLabel.text = model.questionText
            
            cell.bgView1.tag = 0
            cell.bgView2.tag = 1
            cell.bgView3.tag = 2
            
            self.setOptionView(indexPath:indexPath, textLbl: cell.optionLabel1, view: cell.bgView1, radioBtn: cell.radioBtn1, data: model.optionsArr[0] as! NSDictionary, questionId: model.questionId)
            
            self.setOptionView(indexPath:indexPath, textLbl: cell.optionLabel2, view: cell.bgView2, radioBtn: cell.radioBtn2, data: model.optionsArr[1] as! NSDictionary, questionId: model.questionId)
            
            self.setOptionView(indexPath:indexPath, textLbl: cell.optionLabel3, view: cell.bgView3, radioBtn: cell.radioBtn3, data: model.optionsArr[2] as! NSDictionary, questionId: model.questionId)

            //Add button action
            cell.optionButtonTapped = { [unowned self] (selectedCell, sender) -> Void in
                let button = sender as! UIButton
                button.accessibilityIdentifier = model.questionId
                
                   // if (self.ansDict.value(forKey: model.questionId) != nil) {
                        if button == cell.bgBtn1 {
                            if (self.ansDict.value(forKey: model.questionId) as? String == selectedCell.optionLabel1.accessibilityIdentifier) {
                                self.ansDict.removeObject(forKey: model.questionId)
                                tableView.reloadData()
                                return
                            }
                            else {
                                //Add answer into dictionary
                                self.selectAnswer(indexPath: indexPath, view: selectedCell.bgView1)
                            }
                        }
                        else if button == cell.bgBtn2 {
                            if (self.ansDict.value(forKey: model.questionId) as? String == selectedCell.optionLabel2.accessibilityIdentifier) {
                                self.ansDict.removeObject(forKey: model.questionId)
                                tableView.reloadData()
                                return
                            }
                            else {
                                //Add answer into dictionary
                                self.selectAnswer(indexPath: indexPath, view: selectedCell.bgView2)
                            }
                        }
                        else if button == cell.bgBtn3 {
                            if (self.ansDict.value(forKey: model.questionId) as? String == selectedCell.optionLabel3.accessibilityIdentifier) {
                                self.ansDict.removeObject(forKey: model.questionId)
                                tableView.reloadData()
                                return
                            }
                            else {
                                //Add answer into dictionary
                                self.selectAnswer(indexPath: indexPath, view: selectedCell.bgView3)
                            }
                            
                        }
                  //  }
            }

            return cell;
        }
        else if model.questionType == "Rating" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RatingCellId", for: indexPath) as! RatingCell
            cell.tag = indexPath.section
            cell.backgroundColor = cell.contentView.backgroundColor;
            cell.questionLabel.text = model.questionText

            //Check answer is selected
            
            if (self.ansDict.value(forKey: model.questionId) != nil) {
                self.showRatingStatus(cell: cell, value: self.ansDict.value(forKey: model.questionId) as! Int)
            }
            else {
                self.showRateOffStatus(cell: cell)
            }
            
            cell.ratingButtonTapped = { [unowned self] (selectedCell, sender) -> Void in
                let button = sender as! UIButton
                button.accessibilityIdentifier = model.questionId
                self.saveRatingValue(cell: cell, sender: sender)
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellId2", for: indexPath) as! Feedback2CustomCell
            cell.backgroundColor = cell.contentView.backgroundColor;
            cell.questionLabel.text = model.questionText

            cell.answerText.accessibilityIdentifier = model.questionId
            
            cell.answerText.delegate = self
            cell.answerText.layer.cornerRadius = 3.0
            cell.answerText.layer.borderColor = UIColor(rgb: 0xCCCCCC).cgColor
            cell.answerText.layer.borderWidth = 1.0
            
            if (self.ansDict.value(forKey: model.questionId) != nil) {
                cell.answerText.text = self.ansDict.value(forKey: model.questionId) as! String
            }

            return cell;
        }
        
    }
    
    func setOptionView(indexPath: IndexPath , textLbl : UILabel, view : UIView, radioBtn : UIButton, data : NSDictionary, questionId : String)  {
        
        textLbl.text = data["OptionValue"] as? String
        textLbl.accessibilityIdentifier = data["OptionId"] as? String
        
        view.layer.borderColor = UIColor().HexToColor(hexString: "#D7D7D7").cgColor
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 5.0
        view.layer.borderWidth = 1.0
        
        //Check answer is selected
        
        if self.ansDict.count != 0 {
            if (self.ansDict.value(forKey: questionId) as? String == textLbl.accessibilityIdentifier) {
                radioBtn.isSelected = true
                view.backgroundColor = CommonModel.RowHighlightColour
            }else {
                radioBtn.isSelected = false
                view.backgroundColor = UIColor.white
            }
        }
        else {
            radioBtn.isSelected = false
            view.backgroundColor = UIColor.white
        }
    
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        /*self.view.endEditing(true)
        
        let model = feedbackarray[indexPath.section] as FeedbackModel
                
        if model.questionType == "Multiple" {
            
            let cell = tableView.cellForRow(at: indexPath) as! FeedbackCustomCell
            let model = feedbackarray[indexPath.section] as FeedbackModel
            
            
            if (self.ansDict.value(forKey: model.questionId) != nil) {
                if (self.ansDict.value(forKey: model.questionId) as? String == cell.optionLabel.accessibilityIdentifier) {
                    ansDict.removeObject(forKey: model.questionId)
                    tableView.reloadData()
                    return
                }
            }
            //Add answer into dictionary
            self.selectAnswer(indexPath: indexPath, view: cell.bgView)
        }*/
    }
    
    func selectAnswer(indexPath : IndexPath, view: UIView)  {
        
        view.backgroundColor = CommonModel.RowHighlightColour
        view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3,
                       animations: {
                        view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.3) {
                            view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        }
        })
        
        let model = feedbackarray[indexPath.section] as FeedbackModel
//        let key = "Option" + String(indexPath.row+1)
//        let optionDict = model.optionText as Dictionary
        let optionDict = model.optionsArr[view.tag] as! NSDictionary
        model.answerText = optionDict["OptionValue"] as! String        
        ansDict.setValue(optionDict["OptionId"], forKey: model.questionId)
        tableView.reloadData()
    }
    
    func showRateOffStatus(cell : RatingCell)  {
        
        cell.ratingBtn1.isSelected = false
        cell.ratingBtn2.isSelected = false
        cell.ratingBtn3.isSelected = false
        cell.ratingBtn4.isSelected = false
        cell.ratingBtn5.isSelected = false
    }
    
    func showRatingStatus(cell : RatingCell, value: Int)  {
        
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
    
    func saveRatingValue(cell : RatingCell, sender : AnyObject) {
        
        self.showRateOffStatus(cell: cell)
        
        let button = sender as! UIButton
        self.showRatingStatus(cell: cell, value: button.tag)
        
        let model = feedbackarray[cell.tag] as FeedbackModel
        model.answerText = String(button.tag)
        ansDict.setValue(button.tag, forKey: sender.accessibilityIdentifier!!)
       // print("Ans Dict - ", self.ansDict)
    }
    
}

// MARK: - Custom Cell Classes

class Feedback2CustomCell: UITableViewCell
{
    @IBOutlet var questionLabel:UILabel!
    @IBOutlet var answerText:CustomUITextView!
}

class FeedbackMultipleCell: UITableViewCell {
    
    @IBOutlet var questionLabel:UILabel!
    
    @IBOutlet var optionLabel1:UILabel!
    @IBOutlet var radioBtn1:UIButton!
    @IBOutlet var bgView1 : UIView!
    @IBOutlet var bgBtn1:UIButton!
    
    @IBOutlet var optionLabel2:UILabel!
    @IBOutlet var radioBtn2:UIButton!
    @IBOutlet var bgView2 : UIView!
    @IBOutlet var bgBtn2:UIButton!
    
    @IBOutlet var optionLabel3:UILabel!
    @IBOutlet var radioBtn3:UIButton!
    @IBOutlet var bgView3 : UIView!
    @IBOutlet var bgBtn3:UIButton!
    
    var optionButtonTapped: ((FeedbackMultipleCell, AnyObject) -> Void)?
    
    @IBAction func optionButtonTapped(sender: AnyObject) {
        optionButtonTapped?(self, sender)
    }
}


