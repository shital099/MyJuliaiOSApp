//
//  AddPollQuestionsViewController.swift
//  My-Julia
//
//  Created by gco on 24/01/18.
//  Copyright © 2018 GCO. All rights reserved.
//

import UIKit

class AddPollQuestionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    
    var nameStr: String?
    
    var question : String = ""
    var questionModel = PollModel()
//    var listArray:NSMutableArray = []
    var indexPath : NSIndexPath! = nil
    var tablecell : QuestionCell! = nil
    var activityId : String = ""
    var isAddPoll : Bool = true

    var delegate : ActivityQuestionsListViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup delegates */
        tableView.delegate = self
        tableView.dataSource = self
        
        if isAddPoll == true {
          self.title = "Add Poll Question"
        }
        else{
            self.title = "Update Poll Question"
        }
       
        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableView)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddPollQuestionsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Keyboard NSNotification Methods

    @objc func hideKeyboard() {
        tableView.endEditing(true)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            //  self.view.frame.origin.y -= keyboardSize.height
            if tablecell.opt1txt.isFirstResponder || tablecell.opt2txt.isFirstResponder || tablecell.opt3txt.isFirstResponder || tablecell.opt4txt.isFirstResponder {
                self.view.frame.origin.y = -150
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0 //keyboardSize.height
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.view.frame.origin.y = 0
    }
    // MARK: - POST Methods

    func postPollQuestion() {
        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()
        
        let parameter = ["ActivityId": activityId, "EventId": EventData.sharedInstance.eventId, "Session":0, "Questions" : questionModel.questionText, "QuestionType" : "Multiple","CreatedBy": AttendeeInfo.sharedInstance.attendeeId, "Options" : [
            [ "Id" : activityId,  "OptionValue" : questionModel.opt1, "OptionOrder" : "1", "EventId" : EventData.sharedInstance.eventId],
            [ "Id" : activityId,  "OptionValue" : questionModel.opt2, "OptionOrder" : "2", "EventId" : EventData.sharedInstance.eventId],
            [ "Id" : activityId,  "OptionValue" : questionModel.opt3, "OptionOrder" : "3", "EventId" : EventData.sharedInstance.eventId],
            [ "Id" : activityId,  "OptionValue" : questionModel.opt4, "OptionOrder" : "4", "EventId" : EventData.sharedInstance.eventId]
            
            ]
            ] as [String : Any]
        
        print("post poll parameter", parameter)
        NetworkingHelper.postData(urlString: Add_Poll_Speaker_Question, param:parameter as AnyObject, withHeader: false, isAlertShow: true, controller:self,
                                  callback: { response in
                                    //dissmiss Indicator
                                    CommonModel.sharedInstance.dissmissActitvityIndicator()

                                    DispatchQueue.main.async {
                                        self.navigationController?.popViewController(animated: true)
                                        //Show status alert
                                        self.delegate.updateQuestionDelegateCall(isAddPoll: self.isAddPoll)
                                    }

        }, errorBack: { error in
        })
    }

    
    func updatePollQuestion(index : NSInteger) {
        
        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()
        
//        let parameter = ["Id": questionModel.questionsId, "EventId": EventData.sharedInstance.eventId, "ActivityId": activityId, "Session":0, "Questions" : questionModel.questionText, "QuestionType" : "Multiple", "ModifiedBy": AttendeeInfo.sharedInstance.attendeeId, "Options" : questionModel.optionsArr
//            ] as [String : Any]
        
        let parameter = ["Id": questionModel.questionsId, "EventId": EventData.sharedInstance.eventId, "ActivityId": activityId, "Session":0, "Questions" : questionModel.questionText, "QuestionType" : "Multiple", "ModifiedBy": AttendeeInfo.sharedInstance.attendeeId, "Options" : [
            [ "QuestionId" : questionModel.questionsId,  "OptionValue" : questionModel.opt1, "OptionOrder" : 1, "OptionId": questionModel.op1Id, "EventId" : EventData.sharedInstance.eventId, "ModifiedBy": AttendeeInfo.sharedInstance.attendeeId],
            [ "QuestionId" : questionModel.questionsId,  "OptionValue" : questionModel.opt2, "OptionOrder" : 2, "OptionId": questionModel.opt2Id, "EventId" : EventData.sharedInstance.eventId, "ModifiedBy": AttendeeInfo.sharedInstance.attendeeId],
            [ "QuestionId" : questionModel.questionsId,  "OptionValue" : questionModel.opt3, "OptionOrder" : 3, "OptionId": questionModel.opt3Id, "EventId" : EventData.sharedInstance.eventId, "ModifiedBy": AttendeeInfo.sharedInstance.attendeeId],
            [ "QuestionId" : questionModel.questionsId,  "OptionValue" : questionModel.opt4, "OptionOrder" : 4, "OptionId": questionModel.opt4Id, "EventId" : EventData.sharedInstance.eventId, "ModifiedBy": AttendeeInfo.sharedInstance.attendeeId]
            
            ]
            ] as [String : Any]
            
        
//        print(" updateparameter", parameter)
        NetworkingHelper.postData(urlString: Post_Update_Poll_Question, param:parameter as AnyObject, withHeader: false, isAlertShow: true, controller:self,
                                  callback: { response in
//                                    print("update list", response)
         //dissmiss Indicator
        CommonModel.sharedInstance.dissmissActitvityIndicator()
         DBManager.sharedInstance.updateSpeakerPollQuestionsDataIntoDB(question: self.questionModel.questionText, opt1: self.questionModel.opt1, opt2: self.questionModel.opt2, opt3: self.questionModel.opt3, opt4: self.questionModel.opt4, questionsId: self.questionModel.questionsId)

                                    // CommonModel.sharedInstance.showAlertWithStatus(title: Alert_Sucess, message: Update_Poll_success, vc: self)
                                    DispatchQueue.main.async {
                                        self.navigationController?.popViewController(animated: true)
                                        //Show status alert
                                        self.delegate.updateQuestionDelegateCall(isAddPoll: self.isAddPoll)
                                   }

        }, errorBack: { error in
        })
        
    }
    
    // MARK: - UITextView Delegate Methods
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
     func textViewDidChange(_ textView: UITextView) {
//        CommonModel.sharedInstance.showAlertWithStatus(title: Alert_Error, message: Update_Error_Message, vc: self)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(textView.text.count > 500 && range.length == 0) {
            return false
        }
        return true
    }
    
    
    // MARK: - UITableView Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestCell", for: indexPath) as! QuestionCell
        self.tablecell = cell
      
        if isAddPoll == true{
            tablecell.updateBtn.isHidden = true
        }
        else {
            tablecell.sendBtn.isHidden = true
        }
        cell.questInputView.layer.borderWidth = 0.3
        cell.questInputView.layer.borderColor = UIColor.darkGray.cgColor
        cell.questInputView.layer.cornerRadius = 8
        cell.opt1txt.layer.borderWidth = 0.3
        cell.opt1txt.layer.borderColor = UIColor.darkGray.cgColor
        cell.opt1txt.layer.cornerRadius = 8
        
        cell.opt2txt.layer.borderWidth = 0.3
        cell.opt2txt.layer.borderColor = UIColor.darkGray.cgColor
        cell.opt2txt.layer.cornerRadius = 8

        cell.opt3txt.layer.borderWidth = 0.3
        cell.opt3txt.layer.borderColor = UIColor.darkGray.cgColor
        cell.opt3txt.layer.cornerRadius = 8

        cell.opt4txt.layer.borderWidth = 0.3
        cell.opt4txt.layer.borderColor = UIColor.darkGray.cgColor
        cell.opt4txt.layer.cornerRadius = 8

        
        cell.cancelBtn.showButtonTheme()
        cell.updateBtn.showButtonTheme()
        cell.sendBtn.showButtonTheme()
    
        cell.backgroundColor = cell.contentView.backgroundColor;
        cell.questInputView?.text = questionModel.questionText
        cell.opt1txt?.text = questionModel.opt1
        cell.opt2txt?.text = questionModel.opt2
        cell.opt3txt?.text = questionModel.opt3
        cell.opt4txt?.text = questionModel.opt4
 
//        for i in 0..<questionModel.optionsArr.count {
//            print("i", i)
//            print(questionModel.optionsArr.count)
//            let optionDict = questionModel.optionsArr[i] as! NSDictionary
//
//            switch i {
//            case 0:
//                cell.opt1txt.text = optionDict["OptionValue"] as? String
////                cell.opt1txt.accessibilityIdentifier = optionDict["Id"] as? String
//                break
//            case 1:
//                cell.opt2txt.text = optionDict["OptionValue"] as? String
////                cell.opt2txt.accessibilityIdentifier = optionDict["Id"] as? String
//
//                break
//            case 2:
//                cell.opt3txt.text = optionDict["OptionValue"] as? String
////                cell.opt3txt.accessibilityIdentifier = optionDict["Id"] as? String
//
//                break
//            case 3:
//                cell.opt4txt.text = optionDict["OptionValue"] as? String
////                cell.opt4txt.accessibilityIdentifier = optionDict["Id"] as? String
//
//                break
//            default:
//                break
//            }
//        }
//
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    }
    
    
    // MARK: - Button action methods

    @IBAction func onClickOfsendBtnBtn(sender: AnyObject) {
        //imp dont delete ( post binding)
        questionModel.questionText = tablecell.questInputView.text
        questionModel.opt1 = tablecell.opt1txt.text
        questionModel.opt2 = tablecell.opt2txt.text
        questionModel.opt3 = tablecell.opt3txt.text
        questionModel.opt4 = tablecell.opt4txt.text
        //        else
        //        {
        //        tablecell.questInputView.text = ""
        //        tablecell.opt1txt.text = ""
        //        tablecell.opt2txt.text = ""
        //        tablecell.opt3txt.text = ""
        //        tablecell.opt4txt.text = ""
        
        //    }
        if (tablecell.questInputView.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: No_Question_Message, vc: self)
            return
        }
        else if (tablecell.opt1txt.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: No_Option1_Message, vc: self)
            return
        }
        else if (tablecell.opt2txt.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: No_Option2_Message, vc: self)
            return
        }
        else if (tablecell.opt3txt.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: No_Option3_Message, vc: self)
            return
        }
        else if (tablecell.opt4txt.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: No_Option4_Message, vc: self)
            return
            }
        
        if tablecell.opt1txt.text == tablecell.opt2txt.text || tablecell.opt1txt.text == tablecell.opt3txt.text || tablecell.opt1txt.text == tablecell.opt4txt.text{
        CommonModel.sharedInstance.showAlertWithStatus(title: "", message: "Enter unique option to proceed", vc: self)
            return
        }
        else if
            
         tablecell.opt2txt.text == tablecell.opt3txt.text || tablecell.opt2txt.text == tablecell.opt4txt.text{
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: "Enter unique option to proceed", vc: self)
            return
        }
        
        else if tablecell.opt3txt.text == tablecell.opt4txt.text  {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: "Enter unique option to proceed", vc: self)
            return
        }
        if !tablecell.questInputView.text.isEmpty {
            self.postPollQuestion()
        }
        
    }
    
    
    @IBAction func onClickOfcancelBtnBtn(sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickOfUpdateBtn(_ sender: UIButton) {
        
        let index = sender.tag
        tablecell.sendBtn.isHidden = true
        tablecell.updateBtn.isHidden = false
        questionModel.questionText = tablecell.questInputView.text
        questionModel.opt1 = tablecell.opt1txt.text
        questionModel.opt2 = tablecell.opt2txt.text
        questionModel.opt3 = tablecell.opt3txt.text
        questionModel.opt4 = tablecell.opt4txt.text

        if (tablecell.questInputView.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: No_Question_Message, vc: self)
            return
        }
        else if (tablecell.opt1txt.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: No_Option1_Message, vc: self)
            return
        }
        else if (tablecell.opt2txt.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: No_Option2_Message, vc: self)
            return
        }
        else if (tablecell.opt3txt.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: No_Option3_Message, vc: self)
            return
        }
        else if (tablecell.opt4txt.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: No_Option4_Message, vc: self)
            return
        }
        
        if tablecell.opt1txt.text == tablecell.opt2txt.text || tablecell.opt1txt.text == tablecell.opt3txt.text || tablecell.opt1txt.text == tablecell.opt4txt.text{
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: "Enter unique option to proceed", vc: self)
            return
        }
        else if tablecell.opt2txt.text == tablecell.opt3txt.text || tablecell.opt2txt.text == tablecell.opt4txt.text{
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: "Enter unique option to proceed", vc: self)
            return
        }
        else if tablecell.opt3txt.text == tablecell.opt4txt.text  {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: "Enter unique option to proceed", vc: self)
            return
        }

        if !tablecell.questInputView.text.isEmpty {
            self.updatePollQuestion(index: index)
        }
    }
}

// MARK: - Custom Cell Classes
class QuestionCell: UITableViewCell {
    @IBOutlet weak var questInputView: UITextView!
    @IBOutlet weak var opt1txt: UITextField!
    @IBOutlet weak var opt2txt: UITextField!
    @IBOutlet weak var opt3txt: UITextField!
    @IBOutlet weak var opt4txt: UITextField!
    @IBOutlet weak var actNamelbl: UILabel!

    @IBOutlet weak var cancelBtn: DesignableButton!
    @IBOutlet weak var sendBtn: DesignableButton!
    @IBOutlet weak var updateBtn: DesignableButton!
    
}


