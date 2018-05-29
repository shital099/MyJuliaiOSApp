//
//  QuestionsViewController.swift
//  My-Julia
//
//  Created by GCO on 8/2/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit
import MessageUI

class QuestionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var totalCountLbl: UILabel!
    @IBOutlet weak var sessionNameLbl: UILabel!
    @IBOutlet weak var speakerNameLbl: UILabel!
    @IBOutlet weak var queInputView: UIView!
    @IBOutlet weak var queTextView: UITextView!
    @IBOutlet weak var askQueBtn: UIButton!

    var lastHistoryTime : String = ""
    var alert : TKAlert!
    var placeholderLabel : UILabel!
    var timer: Timer!
    var liveTimer: Timer!
    var sessionModel = SessionsModel()
    var listArray:NSMutableArray = []
    var likeButtonTapped: ((QuestionsCustomCell, AnyObject) -> Void)?
    var statusAlert : UIAlertController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //hide global activity finished popup
        isLiveQuestionScreenOpen = true
        
        //Show menu icon in ipad and iphone
       // self.setupMenuBarButtonItems()
        
        //        if IS_IPHONE {
        //            self.setupMenuBarButtonItems()
        //        }

        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableView)
       
        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()

        //Update dyanamic height of tableview cell
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension

        //Change ask question button color according to background color
        self.askQueBtn.backgroundColor = AppTheme.sharedInstance.backgroundColor.darker(by: 40)!

        //Add Placeholder in textview
        placeholderLabel = UILabel()
        placeholderLabel.text = "Type your question here..."
        placeholderLabel.font = UIFont.systemFont(ofSize: (queTextView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        queTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (queTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !queTextView.text.isEmpty
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(QuestionsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        //Show activity name and time
        self.sessionNameLbl.text = self.sessionModel.activityName
      //  self.speakerNameLbl.text = CommonModel.sharedInstance.getAgendaDate(dateStr: self.sessionModel.sortActivityDate).appendingFormat(", \(CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: self.sessionModel.startTime)) - \(CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: self.sessionModel.endTime))")
        self.speakerNameLbl.text = CommonModel.sharedInstance.getAgendaDate(dateStr: self.sessionModel.startActivityDate).appendingFormat(" - %@", CommonModel.sharedInstance.getAgendaDate(dateStr: self.sessionModel.endActivityDate))

       // self.listArray = DBManager.sharedInstance.fetchSessionQuestionsListFromDB(sessionId: self.sessionModel.sessionId, activityId: self.sessionModel.activityId)
        //Fetch question list only activity id basis
        self.listArray = DBManager.sharedInstance.fetchSessionQuestionsListFromDB(sessionId: "", activityId: self.sessionModel.activityId)
        self.totalCountLbl.text = String(format: "%d QUESTIONS", listArray.count)

        ///Fetch Questions data from json
        self.fetchActivityQuestionList()

        // Check Session status
        if sessionModel.isActive {
            askQueBtn.isHidden = false
            liveTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Question_History_Time), target: self, selector: #selector(getRunTimedQuestions), userInfo: nil, repeats: true)
            //self.getCurrentTime()

            //Check Still activity is live or not
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(Question_History_Time), target: self, selector: #selector(disableLiveSession), userInfo: nil, repeats: true)
        }
        else {
            askQueBtn.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (liveTimer != nil) {
            liveTimer.invalidate()
            liveTimer = nil
        }
        
        if (timer != nil) {
            timer.invalidate()
            timer = nil
        }
        
        isLiveQuestionScreenOpen = false
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
//        alert.dismiss(false)
//        alert.customFrame = CGRect(x: ((self.view.frame.size.width - self.alert.customFrame.size.width)/2)+130, y: ((self.view.frame.size.height - SPLIT_WIDTH) - self.alert.customFrame.size.height)/2, width: self.alert.customFrame.size.width , height: self.alert.customFrame.size.height)
//        alert.show(false)
        if alert != nil {
            if alert.isVisible == true {
                alert.dismiss(false)
                self.initializeInputView()
                alert.show(true)
            }
        }
    }

    
    @objc func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Timer Method

    @objc func getRunTimedQuestions()  {
        
        //Fetch new questions
        self.fetchLatestActivityQuestionList()
        if (liveTimer != nil) {
            //    [playTimer invalidate];
            //    playTimer = nil;
        }
    }

    @objc func disableLiveSession()  {
        
        //Check live activity status
        let result = DBManager.sharedInstance.checkCurrentActivityStatus(activityId: self.sessionModel.activityId, isDBClose: true)
        if result == false {
            
            //Hide question pop up
            self.alert.dismiss(true)

            //Disable like button also
            self.sessionModel.isActive = false
            self.tableView.reloadData()
            
            //Disable ask question button
            askQueBtn.isHidden = false

            //Stop timer if activity time end
            if (timer != nil) {
                timer.invalidate()
                timer = nil;
            }
            
            if (liveTimer != nil) {
                liveTimer.invalidate()
                liveTimer = nil
            }
            
            //Show feedback option
            if #available(iOS 8.0, *) {
                let activityName = self.sessionModel.activityName as! String
                let alert = UIAlertController(title: "\(activityName) Session over", message: "Would you like to give feedback for this activity?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Later on", style: UIAlertActionStyle.default, handler:{ (UIAlertAction)in
                    self.navigationController?.popViewController(animated: true)
                }))
                alert.addAction(UIAlertAction(title: "Right now", style: UIAlertActionStyle.default, handler:{ (UIAlertAction)in
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ActivityFeedbackViewController") as! ActivityFeedbackViewController
                    viewController.activityId = self.sessionModel.activityId
                    self.navigationController?.pushViewController(viewController, animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - Alert Methods

    func initializeInputView() {
        let vWidth = AppDelegate.getAppDelegateInstance().window?.frame.size.width
        let vHeight = AppDelegate.getAppDelegateInstance().window?.frame.size.height

        var width : CGFloat = 300
        var height : CGFloat = 250
        var yPos  = (vHeight! - (260 + height))/2
        var xPos = (vWidth! - width)/2

        if IS_IPAD {
            width = 580
            height = 250
            xPos = (vWidth! - width)/2
        }
        else {
            if UIDevice.current.orientation.isLandscape == true {
                height = vHeight! - 220 //remove keyborad height and space
                width = vWidth! - 200 //remove keyborad height and space
            }
            else {
                height = vHeight! - 360 //remove keyborad height and top and below space
            }
            
             yPos = (vHeight! - (200 + height))/2 //remove keyboard height and alert height
             xPos = (vWidth! - width)/2
        }
        
        if alert == nil {
            // >> alert-custom-content-swift
            alert = TKAlert()
            alert.style.headerHeight = 0
            alert.tintColor = UIColor(red: 0.5, green: 0.7, blue: 0.2, alpha: 1)
            //alert.customFrame = CGRect(x: ((self.view.frame.size.width - 50)/2), y: (self.view.frame.size.height - 600)/2, width: (self.view.frame.size.width - 50), height: (self.view.frame.size.height - 600))
            self.queInputView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            alert.contentView.addSubview(self.queInputView)
            alert.customFrame = CGRect(x: xPos, y: yPos, width: width , height: height)
            // << alert-custom-content-swift
            
//             alert.style.centerFrame = false
            alert.style.centerFrame = false
            
            // >> alert-animation-swift
            alert.style.showAnimation = TKAlertAnimation.slideFromBottom;
            alert.style.dismissAnimation = TKAlertAnimation.scale;
            // << alert-animation-swift
            
            // >> alert-tint-dim-swift
            alert.style.backgroundDimAlpha = 0.6;
            alert.style.backgroundTintColor = UIColor.darkGray
            // << alert-tint-dim-swift
            
            // >> alert-anim-duration-swift
            alert.animationDuration = 0.5;
            // << alert-anim-duration-swift
            
            alert.addAction(withTitle: "Cancel") { (TKAlert, TKAlertAction) -> Bool in
                self.queTextView.text = ""
                return true
            }
            
            alert.addAction(withTitle: "Send") { (TKAlert, TKAlertAction) -> Bool in
                
                if (self.queTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
                    self.alert.dismiss(false)
                    CommonModel.sharedInstance.showAlertWithStatus(title: "", message: Ask_Valid_Question, vc: self)
                    return false
                }
                else {
                    self.postQuestion()
                    self.queTextView.text = ""
                    return true
                }
            }
        }
        else {
            placeholderLabel.frame.origin = CGPoint(x: 5, y: (queTextView.font?.pointSize)! / 2)
            self.queInputView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            alert.customFrame = CGRect(x: xPos, y: yPos, width: width , height: height)
        }
    }
    
    func showStatus(message : String, timeout : Double) {

        if statusAlert == nil {
            if #available(iOS 8.0, *) {
                statusAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
                statusAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{ (UIAlertAction)in
                }))
                self.present(statusAlert, animated: true, completion: nil)
            }
        }
        else {
            self.present(statusAlert, animated: true, completion: nil)
        }

        Timer.scheduledTimer(timeInterval: timeout, target: self, selector: #selector(timerExpired), userInfo: nil, repeats: false)
    }
    
    @objc func timerExpired(timer : Timer) {
        statusAlert.dismiss(animated: true, completion: nil)
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
    func fetchActivityQuestionList() {
        
        let urlStr = GetQuestions_List_url.appendingFormat("%@",self.sessionModel.activityId)
        NetworkingHelper.getRequestFromUrl(name:GetQuestions_List_url,  urlString:urlStr, callback: { [weak self] response in

            self?.listArray = DBManager.sharedInstance.fetchSessionQuestionsListFromDB(sessionId: (self?.sessionModel.sessionId)!, activityId: (self?.sessionModel.activityId)!)
            self?.tableView.reloadData()
            
        }, errorBack: { error in
            NSLog("error : %@", error)
        })
    }

    func fetchLatestActivityQuestionList() {
        let paramDict = ["ActivityId":self.sessionModel.activityId  ,"AttendeeId":AttendeeInfo.sharedInstance.attendeeId, "EventId":EventData.sharedInstance.eventId, "Session" : 0, "dtLastDate" : "", "Seconds": Question_History_Time] as [String : Any]
        
        NetworkingHelper.postData(urlString: Get_Latest_Questions_List_url, param:paramDict as AnyObject, withHeader: false, isAlertShow: false, controller:self, callback: { [weak self] response in
            self?.listArray = DBManager.sharedInstance.fetchSessionQuestionsListFromDB(sessionId: (self?.sessionModel.sessionId)!, activityId: (self?.sessionModel.activityId)!)
            self?.totalCountLbl.text = String(format: "%d QUESTIONS", (self?.listArray.count)!)
            self?.tableView.reloadData()
        }, errorBack: { error in
        })
    }
    
    func getCurrentTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        lastHistoryTime = dateFormatter.string(from: Date())
    }

    /*func parseQuestionsData(response: AnyObject) {
        
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

//           // if self.listArray.contains(where: { $0.queId == model.queId }) {
//                // found
//                print("Model Found")
//                let index = listArray.index(of: model)
//                listArray.replaceObject(at: index, with: model)
//            } else {
//                // not
//                // model.userIconUrl = BASE_URL.appending(dict.value(forKey: "IconUrl") as! String!)
//                
//                self.listArray.add(model)
//            }
        }
        
        self.totalCountLbl.text = String(format: "%d QUESTIONS", listArray.count)
        self.tableView.reloadData()
    }*/

    func postQuestion() {
        
        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()

       // let paramDict = ["Question": queTextView.text ,"ActivityId":self.sessionModel.activityId, "CreatedBy": AttendeeInfo.sharedInstance.attendeeId, "EventId":EventData.sharedInstance.eventId, "Session":self.sessionModel.sessionId] as [String : Any]
        let paramDict = ["Question": queTextView.text ,"ActivityId":self.sessionModel.activityId, "CreatedBy": AttendeeInfo.sharedInstance.attendeeId, "EventId":EventData.sharedInstance.eventId, "Session":0] as [String : Any]
        print("Post Question : ",paramDict)

        NetworkingHelper.postData(urlString:PostQuestion_List_url, param:paramDict as AnyObject, withHeader: false, isAlertShow: true, controller:self, callback: { [weak self] response in
            //dissmiss Indicator
            CommonModel.sharedInstance.dissmissActitvityIndicator()

            let responseCode = Int(response.value(forKey: "responseCode") as! String)
            if responseCode == 0 {
                //Show message posted alert message
                self?.showStatus(message: Question_Sent_Message, timeout: 1.0)
                self?.fetchLatestActivityQuestionList()
            }
        }, errorBack: { error in
        })
    }
    
    func postLike(questionId : String, index: Int) {
        
        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()
        
        let paramDict = ["QuestionId": questionId ,"ActivityId":self.sessionModel.activityId, "CreatedBy": AttendeeInfo.sharedInstance.attendeeId, "EventId":EventData.sharedInstance.eventId] as [String : Any]

        NetworkingHelper.postData(urlString:LikeQuestion_List_url, param:paramDict as AnyObject, withHeader: false, isAlertShow: true, controller:self, callback: { [weak self] response in
            //dissmiss Indicator
            CommonModel.sharedInstance.dissmissActitvityIndicator()

            let responseCode = Int(response.value(forKey: "responseCode") as! String)
            if responseCode == 0 {
                let model = self?.listArray[index] as! Questions
                model.isUserLike = !model.isUserLike
                model.queCount = model.isUserLike == false ? model.queCount-1 : model.queCount + 1
                self?.listArray.replaceObject(at: index, with: model)

                DBManager.sharedInstance.updateActivityQuestionsDataIntoDB(isLikes: model.isUserLike, questionCount : String(model.queCount), quesId: model.queId, activityId: model.activityId)

                self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.none)
            }
        }, errorBack: { error in
        })
    }

    // MARK: - Button Action Methods
    
    @IBAction func askButtonTapped(sender: AnyObject) {
        
        //Show input text alert view
        self.initializeInputView()
        
        if alert.isVisible == false {
            alert.show(true)
        }
    }
    
    @IBAction func emailButtonTapped(sender: AnyObject) {
        
        var html = ""
        
        for index in 0 ... listArray.count {
            if index < listArray.count {
                let model = self.listArray[index] as! Questions

                model.queStr = model.queStr.replacingOccurrences(of: "\n", with: "<br>")

                html = html.appendingFormat("<div style='text-align:justify; font-size:14px;font-family:HelveticaNeue;color:#362932;'><b> %@.</b> %@ <br></br> %@ <b> - %@</b></p><br>",String(format:"%d",index+1),model.userNameStr, model.queStr,String(format:"%d",model.queCount))
            }
        }
        CommonModel.sharedInstance.createPDF(content: html, pdfName: "QuestionList")
        
        //Share PDF File
        let filename = String(format: "QuestionList_%@_%@", EventData.sharedInstance.eventId,AttendeeInfo.sharedInstance.attendeeId)
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentoPath = "\(documentsPath)/\(filename).pdf"
        
        var document : NSData!
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: documentoPath){
            document = NSData(contentsOfFile: documentoPath)
        }
        else {
            print("document was not found")
        }
        
        let fileName : String = String(format:"Questions - %@.pdf",self.sessionModel.activityName)
        if MFMailComposeViewController.canSendMail() {
            
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients([AttendeeInfo.sharedInstance.email])
            mailComposerVC.setSubject(fileName)
            mailComposerVC.setMessageBody(String(format:"%@ - %@",self.sessionModel.activityName,self.speakerNameLbl.text!), isHTML: false)
            mailComposerVC.addAttachmentData(document as Data, mimeType:"application/pdf" , fileName: fileName)
            self.present(mailComposerVC, animated: true, completion: nil)
        }
        else {
            CommonModel.sharedInstance.showAlertWithStatus(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", vc: self)
        }
    }
    
    // MARK: - MFMailCompose Delegate Methods
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }

    
    // MARK: - UITextView Delegate Methods
    @objc func textViewDidEndEditing(_ textView: UITextView) {
        
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

        if cell.timeLbl.text == "0" {
            cell.timeLbl.text = "0 Second"
        }
        
        if sessionModel.isActive {
            cell.likeButtonTapped = { [unowned self] (selectedCell, sender) -> Void in
                cell.likeButton.isSelected = !cell.likeButton.isSelected
                //Increase question voting count
                self.postLike(questionId: model.queId, index: indexPath.row)
            }
        }
        else {
            cell.likeButton.isUserInteractionEnabled = false
        }
        
        //Show like button status
        cell.likeButton.isSelected = model.isUserLike

        return cell
    }
}

// MARK: - Custom Cell Classes

class QuestionsCustomCell: UITableViewCell {
    
    var likeButtonTapped: ((QuestionsCustomCell, AnyObject) -> Void)?
    
    @IBOutlet weak var userNameLbl:UILabel!
    @IBOutlet weak var likeButton:UIButton!
    @IBOutlet weak var questionLbl: UILabel!
    @IBOutlet weak var queCountLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        likeButtonTapped?(self, sender)
    }

}

