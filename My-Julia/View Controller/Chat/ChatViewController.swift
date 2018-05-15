//
//  ChatViewController.swift
//  My-Julia
//
//  Created by GCO on 5/10/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UUInputFunctionViewDelegate, UUMessageCellDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var head: MJRefreshHeaderView!
    var chatModel: ChatModel!
    var IFView : UUInputFunctionView!
    var chatGroupModel: ChatGroupModel!
    @IBOutlet weak var bgImageView: UIImageView!

    @IBOutlet weak var chatTableView: UITableView?
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint?
    var detailsBtn: UIBarButtonItem!
    var deleteBtn: UIBarButtonItem!
    
    var previousTime : String = ""
    let disableChatView = UILabel()
    var lastHistoryTime : String = ""
    var timer: Timer!
    var isPausedTimer : Bool = false
    var deleteMsgArray : NSMutableArray = []
    var isFromContactList : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.title = self.chatGroupModel.name

        //Update dyanamic height of tableview cell
        chatTableView?.estimatedRowHeight = 400
        chatTableView?.rowHeight = UITableViewAutomaticDimension
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)

        self.chatTableView?.register(UUMessageCell.self, forCellReuseIdentifier: "UUMessageCellIdentifier")
        self.chatTableView?.backgroundColor = UIColor.clear
        
        // self.initBar()
        self.addRefreshViews()
        self.loadBaseViewsAndData()
        self.chatModel.isGroupChat = self.chatGroupModel.isGroupChat
        
        //        let listArray : NSMutableArray = []
        //        self.chatModel.dataSource = listArray

        //Create delete message button object
        self.deleteBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(ChatViewController.onClickOfDeleteMessageBtn))
        self.detailsBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "info"),  style: .plain, target: self, action: #selector(ChatViewController.onClickOfGroupInfoBtn))

        self.navigationItem.rightBarButtonItems = self.chatGroupModel.isGroupChat == true ? [self.detailsBtn] : []

        //        if !self.chatModel.isGroupChat {
        //            self.navigationItem.rightBarButtonItem = deleteBtn
        //            self.navigationItem.rightBarButtonItem = nil
        //        }
        //        else {
        //            self.navigationItem.rightBarButtonItems = [detailsBtn]
        //        }

        //Fetch all chat history from database
        self.parseChatHistoryData(response: "" as AnyObject, isChatHistory:  true)

        //Fetch chat history
        self.fetchChatHistoryList()
        
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(Chat_History_Time), target: self, selector: #selector(getRunTimedQuestions), userInfo: nil, repeats: true)
        self.getCurrentTime()
        //  self.previousTime = self.lastHistoryTime
        
        //Remove extra lines from tableview
        chatTableView?.tableFooterView = UIView()

        //        self.chatModel.dataSource.removeAllObjects()
        //        self.chatModel.populateRandomDataSource()
        //        self.chatTableView?.reloadData()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveMessage),
            name: NSNotification.Name(rawValue: "ChatMessageNotificationId"),
            object: nil)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //Add gestures in tableview
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ChatViewController.longPressed))
        self.chatTableView?.addGestureRecognizer(longPressRecognizer)
        
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.tapGestureOnCell))
        self.chatTableView?.addGestureRecognizer(tapRecognizer)

        //add notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tableViewScrollToBottom), name: .UIKeyboardDidShow, object: nil)
        
        // self.IFView.textViewInput.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        isPausedTimer = true

        //Remove notification observer
        NotificationCenter.default.removeObserver(self, name: Notification.Name("ChatMessageNotificationId"), object: nil)

//        if (self.isMovingFromParentViewController){
//            // Your code...
//            self.navigationController?.popToRootViewController(animated: false)
//        }

        if isFromContactList == true {
          self.navigationController?.popToRootViewController(animated: false)
        }
    }

    override func viewDidAppear(_ animated: Bool) {

        //Update notification read/unread message count in side menu bar
        let dataDict:[String: Any] = ["Order": self.view.tag, "Flag":Update_Chat_List]
        NotificationCenter.default.post(name: UpdateNotificationCount, object: nil, userInfo: dataDict)

        isPausedTimer = false

        if self.chatGroupModel.isGroupChat == true {
            //Fetch group name from db
            self.chatGroupModel.name = DBManager.sharedInstance.fetchGroupName(groupId: self.chatGroupModel.groupId)
            self.title = self.chatGroupModel.name
        }

        //Show Chat notification view on top
        currentChatAttendeeId = self.chatGroupModel.groupId

        //Open keyboard when chat window open
        //NotificationCenter.default.post(name: .UIKeyboardWillShow, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //Show Chat notification view on top
        currentChatAttendeeId = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        //IFView.setNeedsLayout()
        //self.chatTableView?.reloadData()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        /*if chatGroupModel.dndSetting == true {
         var newFrame : CGRect = disableChatView.frame;
         newFrame.origin.y = size.height - 45
         newFrame.size.width = size.width
         newFrame.size.height -= 64
         disableChatView.frame = newFrame;
         UIView.commitAnimations()
         }
         else {
         */
        var newFrame : CGRect = IFView.frame;
        newFrame.origin.y = size.height - 45
        newFrame.size.width = size.width

        IFView.frame = newFrame;
        IFView.changeInputViewFrame(IFView.frame)
        UIView.commitAnimations()
        // }
        
        //Remove previous message data and load new data with modify frame
        // if self.chatModel.dataSource.count != 0 {
        //  self.chatModel.dataSource.removeAllObjects()
        // }
        //  self.chatModel.populateRandomDataSource()
        
        self.chatTableView?.reloadData()
        self.tableViewScrollToBottom()
    }
    
    // MARK: - Gesture methods

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func longPressed(gestureRecognizer: UILongPressGestureRecognizer)
    {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = gestureRecognizer.location(in: self.chatTableView)
            // print("index : ", self.chatTableView?.indexPathForRow(at: touchPoint) ?? "")
            if (self.chatTableView?.indexPathForRow(at: touchPoint)) != nil {
                print("longpressed in cell only")
                self.changeCellStatus(touchPoint: touchPoint)
            }
            else {
                let selectedCell = self.chatTableView?.cellForRow(at: (self.chatTableView?.indexPathForRow(at: touchPoint))!)
                selectedCell?.backgroundColor = UIColor.clear
            }
        }
    }
    
    @objc func tapGestureOnCell(gestureRecognizer: UITapGestureRecognizer)
    {
        let touchPoint = gestureRecognizer.location(in: self.chatTableView)
        if (self.chatTableView?.indexPathForRow(at: touchPoint)) != nil {
            
            // your code here, get the row for the indexPath or do whatever you want
            print("tap gesture in cell only")
            //If long gesture detected first then only add new message
            if deleteMsgArray.count != 0 {
                self.changeCellStatus(touchPoint: touchPoint)
            }
        }
    }
    
    func changeCellStatus(touchPoint : CGPoint) {
        print("Change status methods....")
        let indexPath : IndexPath = (self.chatTableView?.indexPathForRow(at: touchPoint))!
        // let messageFrame = self.chatModel.dataSource[(indexPath.row)] as! UUMessageFrame
        //if messageFrame.message.from.rawValue == 0 {
        let selectedCell = self.chatTableView?.cellForRow(at: indexPath) as! UUMessageCell

        //Store selected cell
        if deleteMsgArray.contains(indexPath) {
            deleteMsgArray.remove(indexPath)
            //  selectedCell.bgSelectionImage.isHidden = true
        }
        else {
            deleteMsgArray.add(indexPath)
            //  selectedCell.bgSelectionImage.isHidden = false
        }
        self.chatTableView?.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)

        //}
        
        //If none of message selected then hide delete button
        if deleteMsgArray.count == 0 {
            self.navigationItem.rightBarButtonItems = self.chatGroupModel.isGroupChat == true ? [self.detailsBtn] : []
        }
        else {
            self.navigationItem.rightBarButtonItems = self.chatGroupModel.isGroupChat == true ? [self.deleteBtn, self.detailsBtn] : [self.deleteBtn]
        }
    }
    
    // MARK: - NSNotification methods
    
    @objc func receiveMessage(notification: NSNotification) {
        
        let chatM = DBManager.sharedInstance.convertToJsonData(text: notification.object as! String)
        
        //if notification.object is NSDictionary {
        if chatM != nil {
            let data = chatM! as! NSDictionary
            let predicate:NSPredicate = NSPredicate(format: "ChatId CONTAINS[c] %@", data["ChatId"] as! String)
            let filteredArray = ModulesID.sharedInstance.ModuleIDsListArray.filter { predicate.evaluate(with: $0) };

            if filteredArray.count == 0 {
                let messageF = self.setMessageFrame(dict: data)
                self.chatModel.dataSource.add(messageF)
                self.chatTableView?.reloadData()
                self.tableViewScrollToBottom()
            }
        }
    }

    // MARK: - Button Action methods
    
    @objc func onClickOfGroupInfoBtn(sender : AnyObject) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GroupDetailViewController") as! GroupDetailViewController
        vc.chatGroupModel = self.chatGroupModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onClickOfDeleteMessageBtn(sender : AnyObject) {
        
        var paramArray : [Any] = []

        for item in self.deleteMsgArray{
            let indexPath = item as! IndexPath
            let messageFrame = self.chatModel.dataSource[indexPath.row] as! UUMessageFrame
            let paramDict = ["ChatId": messageFrame.message.chatId as String,"FromId":AttendeeInfo.sharedInstance.attendeeId as String, "EventId":EventData.sharedInstance.eventId]
            paramArray.append(paramDict)
        }
        print("Delete parameter : ",paramArray)

        NetworkingHelper.postData(urlString:Chat_Delete_Messages, param:paramArray as AnyObject, withHeader: false, isAlertShow: true, controller:self, callback: { response in
            print("Delete Chat message response : ", response)

            let responseCode = Int(response.value(forKey: "responseCode") as! String)
            if responseCode == 0 {
                DBManager.sharedInstance.deleteChatMessageDataFromDB(chatId: paramArray as NSArray)
                self.deleteMsgArray.removeAllObjects()

                //Fetch all chat history from database
                self.chatModel.dataSource = NSMutableArray(array: DBManager.sharedInstance.fetchChatHistoryMessages(groupId: self.chatGroupModel.groupId, fromId: self.chatGroupModel.fromId, isGroupChat: self.chatGroupModel.isGroupChat, lastFetchTime: "All") as! [UUMessageFrame])
                self.chatTableView?.reloadData()
                self.tableViewScrollToBottom()

                self.navigationItem.rightBarButtonItem = nil
            }
        },
                                  errorBack: { error in
                                    print("Delete chat message errror...",error)
        })
    }

    // MARK: - Webservice Methods

    func fetchChatHistoryList() {

        if self.chatGroupModel.isGroupChat {
//            let urlStr = Chat_Group_History.appendingFormat("FromId=%@&ToId=%@&EventId=%@", self.chatGroupModel.fromId,self.chatGroupModel.groupId,EventData.sharedInstance.eventId)
//
//            NetworkingHelper.getRequestFromUrl(name:Chat_Group_History,  urlString:urlStr, callback: { response in

                let paramDict = ["ToId":self.chatGroupModel.groupId] as [String : Any]

                NetworkingHelper.postData(urlString:Chat_Group_History, param:paramDict as AnyObject, withHeader: false, isAlertShow: false, controller:self, callback: { response in

                  //  print("Group Chat history  : ",response)
                if response is Array<Any> {
                    self.parseChatHistoryData(response: response, isChatHistory:  true)
                }
            }, errorBack: { error in
                NSLog("error : %@", error)
            })
        }
        else {
//            let urlStr = Chat_History.appendingFormat("FromId=%@&ToId=%@&EventId=%@", self.chatGroupModel.fromId,self.chatGroupModel.groupId,EventData.sharedInstance.eventId)
//
//            NetworkingHelper.getRequestFromUrl(name:Chat_History,  urlString:urlStr, callback: { response in
                let paramDict = ["ToId":self.chatGroupModel.groupId] as [String : Any]
                NetworkingHelper.postData(urlString:Chat_History, param:paramDict as AnyObject, withHeader: false, isAlertShow: false, controller:self, callback: { response in

//                print("Chat history  : ",response)
                if response is Array<Any> {
                    self.parseChatHistoryData(response: response, isChatHistory:  true)
                }
            }, errorBack: { error in
                NSLog("error : %@", error)
            })
        }
    }
    
    func parseChatHistoryData(response: AnyObject, isChatHistory: Bool) {
        
        if isChatHistory {

            //            let listArray : NSMutableArray = []
            //            for item in response as! NSArray{
            //                let  dict = item as! NSDictionary
            //
            //                let messageF = self.setMessageFrame(dict: dict)
            //                listArray.add(messageF)
            //            }
            //            self.chatModel.dataSource = listArray
            //            self.chatTableView?.reloadData()
            //            self.tableViewScrollToBottom()

            self.chatModel.dataSource = NSMutableArray(array: DBManager.sharedInstance.fetchChatHistoryMessages(groupId: self.chatGroupModel.groupId, fromId: self.chatGroupModel.fromId, isGroupChat: self.chatGroupModel.isGroupChat, lastFetchTime: "All") as! [UUMessageFrame])
            self.chatTableView?.reloadData()
            self.tableViewScrollToBottom()
            
            if self.chatModel.dataSource.count != 0 {
                self.previousTime = (( self.chatModel.dataSource.lastObject as! UUMessageFrame).message.messageDate)!
            }
        }
        else {
            let listArray = self.chatModel.dataSource as NSMutableArray
            /*let array = DBManager.sharedInstance.fetchChatHistoryMessages(groupId: self.chatGroupModel.groupId, fromId: self.chatGroupModel.fromId, isGroupChat: self.chatGroupModel.isGroupChat, lastFetchTime: self.lastHistoryTime)

             if array.count != 0 {
             for item in array {
             let  messageF = item as! UUMessageFrame
             let predicate:NSPredicate = NSPredicate(format: "message.chatId = %@", messageF.message.chatId)
             let filteredArray = listArray.filter { predicate.evaluate(with: $0) };

             if filteredArray.count == 0 {
             listArray.add(messageF)
             }
             }
             self.chatModel.dataSource = listArray
             self.chatTableView?.reloadData()
             self.tableViewScrollToBottom()
             }*/

            for item in response as! NSArray{
                let  dict = item as! NSDictionary
                let chatId = dict.value(forKey: "ChatId") as! String
                
                let predicate:NSPredicate = NSPredicate(format: "message.chatId = %@", chatId)
                let filteredArray = listArray.filter { predicate.evaluate(with: $0) };
                
                if filteredArray.count == 0 {
                    let messageF = self.setMessageFrame(dict: dict)
                    listArray.add(messageF)
                }
            }

            if listArray.count != 0 {
                self.chatModel.dataSource = listArray
                self.chatTableView?.reloadData()
                self.tableViewScrollToBottom()
            }
        }
    }
    
    func setMessageFrame(dict : NSDictionary) -> UUMessageFrame {
        let messageFrame : UUMessageFrame = UUMessageFrame()
        let message : UUMessage = UUMessage()
        
        let path = dict.value(forKey: "ImageUrl")
        message.pictureString = DBManager.sharedInstance.appendImagePath(path: path ?? "")
        message.setWithDict(dict as! [AnyHashable : Any])
        
        //Check message frame
        let fromId = dict.value(forKey: "FromId") as! String!
        if AttendeeInfo.sharedInstance.attendeeId == fromId {
            message.from = MessageFrom(rawValue: 0)!
        }
        else {
            message.from = MessageFrom(rawValue: 1)!
        }
        
        message.minuteOffSetStart(self.previousTime, end: dict["CreatedDate"] as! String)
        messageFrame.showTime = message.showDateLabel;
        messageFrame.showName = self.chatGroupModel.isGroupChat;
        messageFrame.message = message
        
        if (message.showDateLabel) {
            previousTime = dict["CreatedDate"] as! String
        }
        
        //Check DND (do not disturb setting)
        // if personModel.dndSetting == false {
        return messageFrame
    }
    
    func sendMessage(message : String, paramKey : String) {
        
        //Show Indicator
        //  CommonModel.sharedInstance.showActitvityIndicator()
        
        let paramDict = ["FromId":AttendeeInfo.sharedInstance.attendeeId  ,"ToId":self.chatGroupModel.groupId, paramKey: message , "IsGroupChat" : self.chatGroupModel.isGroupChat, "EventId":EventData.sharedInstance.eventId] as [String : Any]
        print("Post respoonce : ",paramDict)
        
        NetworkingHelper.postData(urlString:Chat_Post_Message, param:paramDict as AnyObject, withHeader: false, isAlertShow: true, controller:self, callback: { response in
            print("Post Chat message response : ", response)
            
            let responseCode = Int(response.value(forKey: "responseCode") as! String)
            if responseCode == 0 {
                
                if response.value(forKey: "responseMsg") is NSDictionary {
                    let listArray = self.chatModel.dataSource as NSMutableArray

                    //Check if message already exit in list
                    let  dict = response.value(forKey: "responseMsg") as! NSDictionary
                    let chatId = dict.value(forKey: "ChatId") as! String
                    
                    /* //Save message into db
                     DBManager.sharedInstance.saveChatMessage(dict: dict)
                     let messageF = DBManager.sharedInstance.fetchChatMessages(chatId: chatId, isGroupChat: self.chatGroupModel.isGroupChat, lastMessageTime: self.previousTime)
                     if messageF.message != nil {
                     self.chatModel.dataSource.add(messageF)
                     self.chatTableView?.beginUpdates()
                     self.chatTableView?.insertRows(at: [IndexPath(row: self.chatModel.dataSource.count-1, section: 0)], with: .automatic)
                     self.chatTableView?.endUpdates()
                     self.tableViewScrollToBottom()
                     }
                     */
                    
                    let predicate:NSPredicate = NSPredicate(format: "message.chatId = %@", chatId)
                    let filteredArray = listArray.filter { predicate.evaluate(with: $0) };
                    
                    if filteredArray.count == 0 {
                        let messageF = self.setMessageFrame(dict: dict)
                        self.chatModel.dataSource.add(messageF)
                        
                        self.chatTableView?.beginUpdates()
                        self.chatTableView?.insertRows(at: [IndexPath(row: self.chatModel.dataSource.count-1, section: 0)], with: .automatic)
                        self.chatTableView?.endUpdates()

                        // self.chatTableView?.reloadData()
                        self.tableViewScrollToBottom()
                    }

                }
                // self.fetchChatHistoryList()
            }
            
        }, errorBack: { error in
        })
    }

    func getCurrentTime() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        lastHistoryTime = dateFormatter.string(from: Date())

    }
    
    func refreshChatHistoryList() {
        
        let paramDict = ["FromId":AttendeeInfo.sharedInstance.attendeeId  ,"ToId":self.chatGroupModel.groupId, "EventId":EventData.sharedInstance.eventId, "HistoryDate" : "", "Seconds": Chat_History_Time] as [String : Any]
        NetworkingHelper.postData(urlString: Chat_Refresh_Chat_history, param:paramDict as AnyObject, withHeader: false, isAlertShow: false, controller:self, callback: { response in

            print("Refresh Chat list responce : ",response)
            
            //            let listArray:[UUMessageFrame] = DBManager.sharedInstance.fetchChatHistoryMessages(groupId: self.chatGroupModel.groupId, fromId: self.chatGroupModel.fromId, isGroupChat: self.chatGroupModel.isGroupChat) as! [UUMessageFrame]
            //            self.chatModel.dataSource = NSMutableArray(array: listArray)
            //            self.chatTableView?.reloadData()
            //            self.tableViewScrollToBottom()
            
            if response is Array<Any> {
                let array = response as! NSArray
                if array.count != 0 {
                    self.parseChatHistoryData(response: response, isChatHistory:  false)
                }
            }
        }, errorBack: { error in
        })
    }

    // MARK: - Timer Method
    
    @objc func getRunTimedQuestions()  {
        
        if isPausedTimer == false {
            //Fetch new questions
            self.refreshChatHistoryList()
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

    func addRefreshViews()  {

        //  __weak typeof(self) weakSelf = self;
        //
        //    //load more
        //    int pageNum = 3;
        //
        //    _head = [MJRefreshHeaderView header];
        //    _head.scrollView = self.chatTableView;
        //    _head.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        //
        //    [weakSelf.chatModel addRandomItemsToDataSource:pageNum];
        //
        //    if (weakSelf.chatModel.dataSource.count > pageNum) {
        //    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:pageNum inSection:0];
        //
        //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //    [weakSelf.chatTableView reloadData];
        //    [weakSelf.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        //    });
        //    }
        //    [weakSelf.head endRefreshing];
        //    };
    }

    func loadBaseViewsAndData()  {

        self.chatModel = ChatModel.init()
        self.chatModel.isGroupChat = false
        self.chatModel.screen_size = self.view.frame.size
        //self.chatModel.populateRandomDataSource()

        var size : CGSize = self.view.frame.size
        print("View frame : ",self.view.frame)
        print("Window frame : ",AppDelegate.getAppDelegateInstance().window?.frame ?? "")

//        if UIDevice.current.orientation.isLandscape {
//            size.height -= 64
//        } else {
//        }

        //Calculate bottom view size
//        if IS_IPAD {
//            size.width -= SPLIT_WIDTH
//        }

        if IS_IPAD {
           //  size.height -= 64

            if self.splitViewController?.displayMode == UISplitViewControllerDisplayMode.allVisible {
                size.width -= SPLIT_WIDTH
            }
        }

        IFView = UUInputFunctionView.init(superVC: self, with:size)
        IFView.delegate = self;
        IFView.backgroundColor = AppTheme.sharedInstance.backgroundColor.darker(by: 40)!
        self.view.addSubview(IFView)

        /*   if chatGroupModel.dndSetting == true {
         disableChatView.frame = CGRect(x: 0, y: size.height-45, width: size.width, height: 45)
         disableChatView.backgroundColor = UIColor.lightGray
         disableChatView.textColor = UIColor.white
         disableChatView.text = Disable_chat_message
         disableChatView.numberOfLines = 0
         disableChatView.sizeToFit()
         disableChatView.textAlignment = .center
         self.view.addSubview(disableChatView)

         // IFView.disableChatView.isHidden = false;
         }
         else {
         IFView = UUInputFunctionView.init(superVC: self, with:size)
         IFView.delegate = self;
         self.view.addSubview(IFView)
         }*/

        //  self.chatTableView?.reloadData()
        // self.tableViewScrollToBottom()
    }

    @objc func keyboardChange(notification: NSNotification) {

        let userInfo : NSDictionary = notification.userInfo! as NSDictionary
        var keyboardEndFrame : CGRect

        if let tmp = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            keyboardEndFrame = tmp.cgRectValue
        }

        keyboardEndFrame = ((userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue)!
        var newFrame : CGRect = IFView.frame;

        //adjust ChatTableView's height
        if notification.name == NSNotification.Name.UIKeyboardWillShow {
            self.bottomConstraint?.constant = keyboardEndFrame.size.height + 45;
            newFrame.origin.y = self.view.frame.size.height - keyboardEndFrame.size.height - 45
        }
        else{
            self.bottomConstraint?.constant = 45;
            newFrame.origin.y = self.view.frame.size.height  - 45
        }

        self.view.layoutIfNeeded()

        //adjust UUInputFunctionView's originPoint
        //            var newFrame : CGRect = IFView.frame;
        //            newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height;
        //            IFView.frame = newFrame;

        newFrame.size.width = self.view.frame.size.width
        IFView.frame = newFrame;
        IFView.changeInputViewFrame(IFView.frame)
        self.chatTableView?.reloadData()
        self.tableViewScrollToBottom()
    }

    //tableView Scroll to bottom

    @objc func tableViewScrollToBottom() {
        if self.chatModel.dataSource != nil {

            if self.chatModel.dataSource.count==0 {
                return
            }
            let indexPath : NSIndexPath = NSIndexPath.init(row: self.chatModel.dataSource.count-1, section: 0)
            self.chatTableView?.scrollToRow(at: indexPath as IndexPath, at: UITableViewScrollPosition.bottom, animated: false)
        }

    }
    

    // #pragma mark - InputFunctionViewDelegate

    func uuInputFunctionView(_ funcView: UUInputFunctionView!, sendMessage message: String!) {

        let dict : NSDictionary  = ["strContent": message, "type": MessageType.UUMessageTypeText.rawValue]
        //funcView.changeSendBtn(withPhoto: true)
        funcView.textViewInput.text = ""

        self.dealTheFunctionData(dic: dict)
    }

    func uuInputFunctionView(_ funcView: UUInputFunctionView!, sendPicture image: UIImage!) {

        let dic : NSDictionary = ["picture": image,"type": MessageType.UUMessageTypePicture.rawValue ]
        self.dealTheFunctionData(dic: dic)
    }

    func uuInputFunctionView(_ funcView: UUInputFunctionView!, sendVoice voice: Data!, time second: Int) {
        let dic : NSDictionary = ["voice": voice, "strVoiceTime" : second,"type": MessageType.UUMessageTypeVoice.rawValue, "strContent":"" ]
        self.dealTheFunctionData(dic: dic)
    }

    func dealTheFunctionData(dic:NSDictionary) {

        // self.chatModel.addSpecifiedItem(dic as! [AnyHashable : Any])
        let type = dic.value(forKey: "type") as! Int

        switch type {
        case MessageType.UUMessageTypeText.rawValue:
            let encryptedString = (CryptLib.sharedManager() as AnyObject).encryptPlainText(with: dic.value(forKey: "strContent") as! String)
            self.sendMessage(message: encryptedString! , paramKey: "Message")
            break
        case MessageType.UUMessageTypePicture.rawValue:
            let imageData = UIImageJPEGRepresentation(dic.value(forKey: "picture") as! UIImage, 0)
            let base64String = imageData?.base64EncodedString()
            self.sendMessage(message: base64String!, paramKey: "MsgImage")
            break
        case MessageType.UUMessageTypeVoice.rawValue:
            break
        default:
            break
        }

        //  self.chatTableView?.reloadData()
        //self.tableViewScrollToBottom()
    }

    // MARK: - UITableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.chatModel.dataSource != nil {
            return self.chatModel.dataSource.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.chatModel.dataSource[indexPath.row] as! UUMessageFrame).cellHeight
        //return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "UUMessageCellIdentifier", for: indexPath) as! UUMessageCell
        cell.backgroundColor = cell.contentView.backgroundColor;

        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        let messageFrame = self.chatModel.dataSource[indexPath.row] as! UUMessageFrame

        cell.setMessagesFrame(messageFrame)

        if messageFrame.message.from.rawValue == 1 {
            cell.btnContent.setBackgroundImage(cell.btnContent.backgroundImage(for: .normal)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
            cell.btnContent.tintColor = AppTheme.sharedInstance.backgroundColor.darker(by: 35)!
        }
        else{
            cell.btnContent.setBackgroundImage(cell.btnContent.backgroundImage(for: .normal)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
            cell.btnContent.tintColor = AppTheme.sharedInstance.backgroundColor.darker(by: 45)!
        }

        //show selectection of cell
        if deleteMsgArray.count != 0 {
            if deleteMsgArray.contains(indexPath) {
                cell.bgSelectionImage.isHidden = false
            }
            else {
                cell.bgSelectionImage.isHidden = true
            }
        }
        else {
            cell.bgSelectionImage.isHidden = true
        }
        return cell
    }

    //  #pragma mark - cellDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select ")
    }
    
    func cellContentDidClick(_ cell: UUMessageCell!, image contentImage: UIImage!) {
        print("cellContentDidClick ")
    }
    
    func headImageDidClick(_ cell: UUMessageCell!, userId: String!) {
        CommonModel.sharedInstance.showAlertWithStatus(title: "", message: cell.messageFrame.message.strName, vc: self)
        print("cellContentDidClick ")
    }
}
