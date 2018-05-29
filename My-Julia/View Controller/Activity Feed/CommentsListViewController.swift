//
//  CommentsListViewController.swift
//  My-Julia
//
//  Created by GCO on 7/17/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit
import SafariServices

class CommentsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, RTLabelDelegate, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var viewBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    var placeholderLabel : UILabel!
    
    var listArray:NSMutableArray = []
    var feedModel : ActivityFeedsModel!
    var index : Int!
    var delegate : ActivityCommentDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Comments"
        
        sendButton.isEnabled = false
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        tableView.tableFooterView = UIView()
        
        //Update dyanamic height of tableview cell
        tableView?.estimatedRowHeight = 700
        tableView?.rowHeight = UITableViewAutomaticDimension
        
        sendButton.layer.cornerRadius = 5.0
        commentTextView.layer.cornerRadius = 5.0
        commentTextView.layer.borderColor = UIColor().HexToColor(hexString: "#DDDDDD", alpha: 1.0).cgColor
        commentTextView.layer.borderWidth = 1.0
        commentTextView.backgroundColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange), name: .UIKeyboardWillHide, object: nil)

        //Add Placeholder in textview
        commentTextView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Enter your comment..."
        placeholderLabel.font = UIFont.systemFont(ofSize: (commentTextView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        commentTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (commentTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !commentTextView.text.isEmpty
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CommentsListViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //Fetch data from Sqlite database
        self.listArray = DBManager.sharedInstance.fetchActivityFeedsCommentsDataFromDB(activityFeedId: self.feedModel.id).mutableCopy() as! NSMutableArray

        self.getComments()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.delegate.updateCommentCountDelegate(activityIndex:index , count: String(format: "%d", self.listArray.count))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func scrollToBottom(){
        DispatchQueue.global(qos: .background).async {
            let indexPath = IndexPath(row: self.listArray.count-2, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    // MARK: - Keyboard NSNotification Methods
    
    func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            //self.view.frame.origin.y -= keyboardSize.height
            self.view.frame.origin.y = 150
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0 //keyboardSize.height
        }
    }

    @objc func keyboardChange(notification: NSNotification) {
        
        let userInfo : NSDictionary = notification.userInfo! as NSDictionary
        var keyboardEndFrame : CGRect

//        var animationDuration : TimeInterval
//        let animationCurve : UIViewAnimationCurve
       // let rawAnimationCurveValue = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue
       // animationCurve = UIViewAnimationCurve(rawValue: Int(rawAnimationCurveValue))!
       // animationDuration = TimeInterval(UIViewAnimationCurve(rawValue: Int((userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).uintValue))!.rawValue)
        
        if let tmp = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            keyboardEndFrame = tmp.cgRectValue
        }
        
        keyboardEndFrame = ((userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue)!
        
//        UIView.beginAnimations(nil, context: nil)
//        UIView.setAnimationDuration(animationDuration)
//        UIView.setAnimationCurve(animationCurve)
        
        var newFrame : CGRect = self.commentView.frame;
        
        //adjust ChatTableView's height
        if notification.name == NSNotification.Name.UIKeyboardWillShow {
            self.viewBottomContraint?.constant = keyboardEndFrame.size.height + self.commentView.frame.size.height;
            //  newFrame.origin.y = 100 //self.view.frame.size.height - (keyboardEndFrame.size.height + self.commentView.frame.size.height)
            newFrame.origin.y = self.view.frame.size.height - keyboardEndFrame.size.height - newFrame.size.height
            
        }
        else{
            self.viewBottomContraint?.constant = 0;
            newFrame.origin.y = self.view.frame.size.height  - self.commentView.frame.size.height
        }
        
        self.view.layoutIfNeeded()
        
        self.commentView.frame = newFrame;
        self.tableView.frame.size.height = newFrame.origin.y
        self.tableView.updateConstraints()
        
        if self.listArray.count==0 {
            return
        }
        let indexPath : NSIndexPath = NSIndexPath.init(row: self.listArray.count-1, section: 0)
        self.tableView?.scrollToRow(at: indexPath as IndexPath, at: UITableViewScrollPosition.bottom, animated: false)
    }

    // MARK: - Webservice Methods

    func getComments() {
        
        NetworkingHelper.getRequestFromUrl(name:Get_Comments_url,  urlString: Get_Comments_url.appendingFormat(self.feedModel.id), callback: { [weak self] response in
            
            //Fetch data from Sqlite database
            self?.listArray = DBManager.sharedInstance.fetchActivityFeedsCommentsDataFromDB(activityFeedId: (self?.feedModel.id)!).mutableCopy() as! NSMutableArray
            self?.tableView.reloadData()
            
          //  DBManager.sharedInstance.fe(response: response)

           /* if response is Dictionary<String, Any> {
                let  dict = response as! NSDictionary
                let  arr = dict.value(forKey: "UserComments") as! [AnyObject] as NSArray
                self.listArray = arr.mutableCopy() as! NSMutableArray
            }
            else if response is NSArray {
                let  arr = response as! NSArray

                self.listArray = arr.mutableCopy() as! NSMutableArray
            }
 
            self.tableView.reloadData()
 */
           // self.scrollToBottom()
            
        }, errorBack: { error in
        })
    }
    
    // MARK: - UITextView Delegate Methods
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        if !(commentTextView.text.trimmingCharacters(in: .whitespaces).isEmpty) {
            sendButton.isEnabled = true
        }
        else {
            sendButton.isEnabled = false
        }
    }


    // MARK: - Button Action Methods

    @IBAction func onClickOfSendButtonClick(sender: AnyObject) {
        
        if commentTextView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: Enter_Comment_Text, vc: self)
            return
        }

        commentTextView.resignFirstResponder()

        // Create an instance of HTMLConverter.
        let converter : HTMLConverter = HTMLConverter()

        // Prepare an input text.
        let input : String = self.commentTextView.text

        // Convert the plain text into an HTML text using the converter.
        let output : String = converter.toHTML(input)

        let paramDict = ["ActivityFeedId": feedModel.id,"comment":output,"AttendeeId":AttendeeInfo.sharedInstance.attendeeId] as [String : Any]

        NetworkingHelper.postData(urlString:Post_Activity_Comment_url, param:paramDict as AnyObject, withHeader: false, isAlertShow: true, controller:self, callback: { [weak self] response in
            
            //dissmiss Indicator
            //CommonModel.sharedInstance.dissmissActitvityIndicator()
            if response is NSDictionary {
                if (response.value(forKey: "responseCode") != nil) {

                    let model = FeedsCommentModel()
                    model.commentId = "" //(results?.string(forColumn: "ActivityFeedID"))!
                    model.messageText = output
                    model.name = AttendeeInfo.sharedInstance.attendeeName
                    model.createdDate = "" //(results?.string(forColumn: "CreatedDate"))!
                    model.userIconUrl = AttendeeInfo.sharedInstance.iconUrl
                    model.userId = AttendeeInfo.sharedInstance.attendeeId
                    self?.listArray.add(model)
                    self?.tableView.reloadData()

                    self?.commentTextView.text = ""
                    self?.sendButton.isEnabled = false
                    self?.placeholderLabel.isHidden = !(self?.commentTextView.text.isEmpty)!
                }
            }
            else {
            }
        },
                                  errorBack: { error in
                                    NSLog("error : %@", error)
        })
    }
   
    // MARK: - UITableView DataSource Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! CommentsCustomCell
        cell.backgroundColor = cell.contentView.backgroundColor;
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        let model = self.listArray[indexPath.row] as! FeedsCommentModel
        cell.nameLabel.text = model.name
      //  cell.descLabel.text = model.messageText

        cell.messageLbl.text = model.messageText
        cell.messageLbl.delegate = self
        cell.messageLbl.lineBreakMode = RTTextLineBreakModeWordWrapping
        // cell.messageLbl.sizeToFit()

        let string = model.messageText.appending(String(format:"<style>body{font-family: '%@'; font-size:%fpx;}</style>",cell.messageLbl.font.fontName,cell.messageLbl.font.pointSize))
         cell.descLabel.attributedText = CommonModel.sharedInstance.stringFromHtml(string: string)

        if !model.userIconUrl.isEmpty {
            let url = NSURL(string:model.userIconUrl)! as URL
            cell.userImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "user"))
            cell.userImageView?.layer.cornerRadius = cell.userImageView.frame.size.height/2
            cell.userImageView.clipsToBounds = true
        }
        else {
            cell.userImageView.image = #imageLiteral(resourceName: "user")
        }

//        cell.nameLabel?.text  = DBManager.sharedInstance.isNullString(str: dict.value(forKey: "Name") as Any)
//        cell.descLabel?.text  = DBManager.sharedInstance.isNullString(str: dict.value(forKey: "comment") as Any)
//        let url = NSURL(string:DBManager.sharedInstance.appendImagePath(path: dict.value(forKey: "iconurl") ?? ""))! as URL
//        cell.userImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "user"))

        return cell
    }

    //MARK:- RTLabel Delegate Dismiss

    func rtLabel(_ rtLabel: Any!, didSelectLinkWith url: URL!) {
        //   print("did select url %@", url)
        let urlStr = url.absoluteString
        var nUrl : URL = url
        if urlStr.lowercased().hasPrefix("http://") || urlStr.lowercased().hasPrefix("https://") {
        }
        else {
            if URL (string: String(format:"http://%@", urlStr)) != nil {
                nUrl = URL (string: String(format:"http://%@", urlStr))!
            }
        }

        if url != nil {
            let svc = SFSafariViewController(url: nUrl)
            svc.delegate = self
            self.present(svc, animated: true, completion: nil)
        }
    }

    //MARK:- SafatriViewConroller Dismiss

    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Custom Cell Classes

class CommentsCustomCell: UITableViewCell {
    
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var userImageView:UIImageView!
    @IBOutlet var descLabel:UILabel!
    @IBOutlet var messageLbl:RTLabel!

}

