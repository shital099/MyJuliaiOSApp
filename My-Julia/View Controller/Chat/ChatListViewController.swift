//
//  ChatListViewController.swift
//  EventApp
//
//  Created by GCO on 5/8/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    var deleteBtn: UIBarButtonItem!

    var filtered:[ChatGroupModel] = []
    var dataDict = [String: Array<ChatGroupModel>]()
    //var listArray:NSMutableArray = []
    let searchController = UISearchController(searchResultsController: nil)
    var isGroupList: Bool = false
    var deleteListArray : NSMutableArray = []
    var longPressRecognizer : UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup delegates */
        tableView.delegate = self
        tableView.dataSource = self
        
        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()

        //Change add button
        UIColor().setIconColorImageToButton(button: addButton, image:"Add_chat")
        
        //Set segment tint color
        self.segmentControl.tintColor = AppTheme.sharedInstance.backgroundColor.darker(by: 40)!
        
        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableView)
        
        //Add gestures in tableview
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ChatViewController.longPressed))
        self.tableView?.addGestureRecognizer(longPressRecognizer)

        //Fetch chat list from db
        //self.dataDict["Contacts"] = DBManager.sharedInstance.fetchChatListDataFromDB(isGroupList: false) as? [ChatGroupModel]
        //self.dataDict["Groups"] = DBManager.sharedInstance.fetchChatListDataFromDB(isGroupList: true) as? [ChatGroupModel]

        self.deleteBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(ChatListViewController.onClickOfDeleteMessageBtn))
        self.navigationItem.rightBarButtonItem = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {

        //Fetch chat list from db
        self.dataDict["Contacts"] = DBManager.sharedInstance.fetchChatListDataFromDB(isGroupList: false) as? [ChatGroupModel]
        self.dataDict["Groups"] = DBManager.sharedInstance.fetchChatListDataFromDB(isGroupList: true) as? [ChatGroupModel]

        self.tableView.reloadData()

        //Fetch user list
        self.fetchContactsList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Gesture methods

    @objc func longPressed(gestureRecognizer: UILongPressGestureRecognizer)
    {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            if (self.tableView?.indexPathForRow(at: touchPoint)) != nil {
                print("long pressed in cell only")
                let indexPath : IndexPath = (self.tableView?.indexPathForRow(at: touchPoint))!
                self.changeCellStatus(indexPath: indexPath)
            }
            else {
                let selectedCell = self.tableView?.cellForRow(at: (self.tableView?.indexPathForRow(at: touchPoint))!)
                selectedCell?.backgroundColor = UIColor.clear
            }
        }
    }
    
    func changeCellStatus(indexPath : IndexPath) {
        
        //Store selected cell
        if deleteListArray.contains(indexPath) {
            deleteListArray.remove(indexPath)
        }
        else {
            deleteListArray.add(indexPath)
        }
        
        //If none of message selected then hide delete button
        if deleteListArray.count == 0 {
            self.navigationItem.rightBarButtonItem = nil
        }
        else {
            self.navigationItem.rightBarButtonItem = self.deleteBtn
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destinationVC = segue.destination
        if destinationVC is  ChatViewController {
            let vc = destinationVC as! ChatViewController
            if searchController.isActive && searchController.searchBar.text != "" {
                vc.chatGroupModel = filtered[(self.tableView.indexPathForSelectedRow?.row)!]
            }
            else {
                if self.isGroupList {
                    vc.chatGroupModel = self.dataDict["Groups"]?[(self.tableView.indexPathForSelectedRow?.row)!]
                }
                else {
                    vc.chatGroupModel = self.dataDict["Contacts"]?[(self.tableView.indexPathForSelectedRow?.row)!]
                }
            }
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
            masterVC =  self.menuContainerViewController.leftMenuViewController as! MenuViewController!
        }
        else {
            masterVC = self.splitViewController?.viewControllers.first
        }
        
        if ((masterVC as? MenuViewController) != nil) {
            (masterVC as! MenuViewController).toggleLeftSplitMenuController()
        }
    }
    
    // MARK: - Button Action Method
    
    @IBAction func segmentChanged(_ sender: Any) {
        
        let segmentControl = sender as! UISegmentedControl
        if segmentControl.selectedSegmentIndex == 0 {
            self.isGroupList = false
            self.longPressRecognizer.isEnabled = true
        }
        else {
            self.isGroupList = true
            self.longPressRecognizer.isEnabled = false
            self.navigationItem.rightBarButtonItem = nil

            //Remove all object from array
            if deleteListArray.count != 0 {
                self.deleteListArray.removeAllObjects() 
            }
        }
        
        //refresh tableview
        self.tableView.reloadData()
    }
    
    @objc func onClickOfDeleteMessageBtn(sender : AnyObject) {
        
        var paramArray : [Any] = []
        
        for item in self.deleteListArray{
            let indexPath = item as! IndexPath
            let model = (self.dataDict["Contacts"]?[indexPath.row])!
            let paramDict = ["FromId": model.fromId as String,"ToId": model.groupId as String,"EventId":EventData.sharedInstance.eventId as String]
            paramArray.append(paramDict)
        }
        
        print("Delete List ",paramArray)

        NetworkingHelper.postData(urlString:Chat_Delete_Conversession, param:paramArray as AnyObject, withHeader: false, isAlertShow: true, controller:self, callback: { response in
            print("Delete Chat List response : ", response)

            let responseCode = Int(response.value(forKey: "responseCode") as! String)
            if responseCode == 0 {
                DBManager.sharedInstance.deleteChatConversionFromDB(groupId: paramArray as NSArray)
                self.deleteListArray.removeAllObjects()

                self.dataDict["Contacts"] = DBManager.sharedInstance.fetchChatListDataFromDB(isGroupList: false) as? [ChatGroupModel]
                self.tableView.reloadData()

                self.navigationItem.rightBarButtonItem = nil
            }
        },
                                  errorBack: { error in
                                    print("Delete chat List errror...",error)
        })
    }

    // MARK: - Webservice Methods
    
    func fetchContactsList() {
        
        let urlStr = Get_AllModuleDetails_url.appendingFormat("Flag=%@",Chat_Contact_List)
        NetworkingHelper.getRequestFromUrl(name:Chat_Contact_List,  urlString:urlStr, callback: { response in
            if response is Array<Any> {
              //  print("Chat List : ",response)
                //Update side menu row
                self.changeChatCount()

                //Fetch data from Sqlite database
                self.dataDict["Contacts"] = DBManager.sharedInstance.fetchChatListDataFromDB(isGroupList: false) as? [ChatGroupModel]
                self.dataDict["Groups"] = DBManager.sharedInstance.fetchChatListDataFromDB(isGroupList: true) as? [ChatGroupModel]
                self.tableView.reloadData()

                //                if response is NSArray {
                //                    self.parseChatData(response: response)
                //                }
            }
        }, errorBack: { error in
            NSLog("error : %@", error)
        })
    }
    
    func parseChatData(response: AnyObject) {
        if response is NSArray {
            
            let listArray : NSMutableArray = []
            let arr = response as! NSArray
            let rawDict = arr[0] as! NSDictionary
            
            //Parse chat contacts
            //        for item in response["Contacts"] as! NSArray {
            if (rawDict.value(forKey:"attChatList") as? NSNull) == nil {
                for item in rawDict["attChatList"] as! NSArray {
                    let  dict = item as! NSDictionary
                    let model = ChatGroupModel()
                    model.groupId = DBManager.sharedInstance.isNullString(str: dict.value(forKey: "AttendeeId") as Any)
                    model.fromId = DBManager.sharedInstance.isNullString(str: dict.value(forKey: "AttendeeId") as Any)
                    model.groupCreatedUserId = AttendeeInfo.sharedInstance.attendeeId //DBManager.sharedInstance.isNullString(str: dict.value(forKey: "AttendeeId") as Any)
                    model.dateStr = DBManager.sharedInstance.isNullString(str: dict.value(forKey: "LastMessageSent") as Any)
                    model.name = DBManager.sharedInstance.isNullString(str: dict.value(forKey: "Name") as Any)
                    let path = dict.value(forKey: "ImgPath")
                    model.iconUrl = DBManager.sharedInstance.appendImagePath(path: path ?? "")
                    model.isGroupChat = false
                    model.dndSetting = dict.value(forKey: "IsDND") as! Bool
                    model.visibilitySetting = dict.value(forKey: "IsVisible") as! Bool
                    
                    if (dict.value(forKey: "LastMessage") as? NSNull) == nil {
                        let msg = dict.value(forKey: "LastMessage") as! String
                        if msg == "image" {
                            model.messageImgUrl = msg
                            model.lastMessage = ""
                        }
                        else {
                            model.messageImgUrl = ""
                            model.lastMessage = (CryptLib.sharedManager() as AnyObject).decryptCipherText(with: msg)
                        }
                    }
                    else {
                        model.lastMessage = ""
                        model.messageImgUrl = ""
                    }
                    listArray.add(model)
                }
            }
            
            self.dataDict["Contacts"] = listArray as? [ChatGroupModel]
            
            if listArray.count != 0 {
                listArray.removeAllObjects()
            }
            
            //Parse chat groups
            //  for item in response["Groups"] as! NSArray {
            if (rawDict.value(forKey:"attGroupChatList") as? NSNull) == nil {
                for item in rawDict["attGroupChatList"] as! NSArray {
                    
                    let  dict = item as! NSDictionary
                    let model = ChatGroupModel()
                    model.groupId = DBManager.sharedInstance.isNullString(str: dict.value(forKey: "GroupId") as Any)
                    model.fromId = DBManager.sharedInstance.isNullString(str: dict.value(forKey: "GroupId") as Any)
                    model.name = DBManager.sharedInstance.isNullString(str: dict.value(forKey: "GroupName") as Any)
                    model.groupCreatedUserId = DBManager.sharedInstance.isNullString(str: dict.value(forKey: "CreatedBy") as Any)
                    model.dateStr = DBManager.sharedInstance.isNullString(str: dict.value(forKey: "LastMessageSent") as Any)
                    
                    let path = dict.value(forKey: "ImgPath")
                    model.iconUrl = DBManager.sharedInstance.appendImagePath(path: path ?? "")
                    model.isGroupChat = true
                    if (dict.value(forKey: "LastMessage") as? NSNull) == nil {
                        let msg = dict.value(forKey: "LastMessage") as! String
                        if msg == "image" {
                            model.messageImgUrl = msg
                            model.lastMessage = ""
                        }
                        else {
                            model.messageImgUrl = ""
                            model.lastMessage = (CryptLib.sharedManager() as AnyObject).decryptCipherText(with: msg)
                        }
                    }
                    else {
                        model.lastMessage = ""
                        model.messageImgUrl = ""
                    }
                    listArray.add(model)
                }
            }
            self.dataDict["Groups"] = listArray as? [ChatGroupModel]
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: - UITableView Delegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.dataDict.count != 0 {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filtered.count
        }
        else {
            if self.dataDict.count != 0 {
                
                if self.isGroupList {
                    return (dataDict["Groups"]?.count)!
                }
                
                return (dataDict["Contacts"]?.count)!
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! ChatListCell
        cell.backgroundColor = cell.contentView.backgroundColor;
        
        var model : ChatGroupModel
        
        if self.isGroupList {
            model = (self.dataDict["Groups"]?[indexPath.row])!
          //  print("Group name : %@,\n Image Path : %@",model.name,model.iconUrl)
            if model.iconUrl.isEmpty {
                cell.userIconImg.image = #imageLiteral(resourceName: "group_icon")
            }
            else {
                SDImageCache.shared().removeImage(forKey: model.iconUrl, withCompletion: nil)
                cell.userIconImg.sd_setImage(with: URL(string:model.iconUrl), placeholderImage: #imageLiteral(resourceName: "group_icon"))
                cell.userIconImg?.layer.cornerRadius = cell.userIconImg.frame.size.height/2
                cell.userIconImg.contentMode = UIViewContentMode.scaleAspectFill
                cell.userIconImg.layer.borderColor = UIColor.gray.cgColor
                cell.userIconImg.layer.borderWidth = 1.0
                cell.userIconImg.clipsToBounds = true
            }
        }
        else {
            model = (self.dataDict["Contacts"]?[indexPath.row])!
            
            if model.visibilitySetting == true && !model.iconUrl.isEmpty {
                cell.userIconImg.sd_setImage(with: URL(string:model.iconUrl), placeholderImage: #imageLiteral(resourceName: "user"))
                cell.userIconImg?.layer.cornerRadius = cell.userIconImg.frame.size.height/2
                cell.userIconImg.layer.borderColor = UIColor.gray.cgColor
                cell.userIconImg.layer.borderWidth = 1.0
                cell.userIconImg.clipsToBounds = true
            }
            else  {
                cell.userIconImg.image = #imageLiteral(resourceName: "user")
            }
        }
        cell.nameLabel?.text = model.name
        //Show last modified date of chat
        cell.timeLbl.text = model.dateStr == "" ? "" : CommonModel.sharedInstance.getChatListDate(dateStr: model.modifiedDateStr)
        cell.statusImg.isHidden  = model.lastMessage == "" ? true : model.listStatus

        if model.lastMessage == "" {
            cell.cameraImg.isHidden = true
            cell.photoLblLabel.isHidden = true
            cell.photoLblLabel?.text = ""
            cell.lastMsgLblLabel?.text = ""
        }
        else if model.lastMessage == "image" {
            cell.cameraImg.isHidden = false
            cell.photoLblLabel.isHidden = false
            cell.photoLblLabel?.text = "Photo"
            cell.lastMsgLblLabel.isHidden = true
        }
        else {
            cell.cameraImg.isHidden = true
            cell.photoLblLabel.isHidden = true
            cell.lastMsgLblLabel.isHidden = false
            cell.lastMsgLblLabel?.text = (CryptLib.sharedManager() as AnyObject).decryptCipherText(with: model.lastMessage)
        }
        
        //show list history delete cell
        if deleteListArray.contains(indexPath) {
            cell.selectionImgView.isHidden = false
            cell.selectedIconImgview.isHidden = false
        }
        else {
            cell.selectionImgView.isHidden = true
            cell.selectedIconImgview.isHidden = true
        }

        return cell
    }
    
    // MARK:-  UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        //Show chat list when gesture is disable
        if longPressRecognizer.isEnabled == true && deleteListArray.count != 0 {
            //If long gesture detected first then only add new message
            self.changeCellStatus(indexPath: indexPath)
        }
        else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            if searchController.isActive && searchController.searchBar.text != "" {
                vc.chatGroupModel = filtered[(self.tableView.indexPathForSelectedRow?.row)!]
            }
            else {
                if self.isGroupList {
                    vc.chatGroupModel = self.dataDict["Groups"]?[indexPath.row]
                }
                else {
                    vc.chatGroupModel = self.dataDict["Contacts"]?[indexPath.row]
                }
            }

            //Update database status for chat hostory read
            DBManager.sharedInstance.updateChatListStatusIntoDB(groupId: vc.chatGroupModel.groupId)

            //Update side menu row
            self.changeChatCount()

            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func changeChatCount() {
        let userDict:[String: Bool] = ["isClickOnNotification": false]
        NotificationCenter.default.post(name: ChatNotification, object: "", userInfo: userDict)
    }

}

// MARK: - Custom Cell Classes

class ChatListCell: UITableViewCell {
    
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var userIconImg:UIImageView!
    @IBOutlet var lastMsgLblLabel:UILabel!
    @IBOutlet var photoLblLabel:UILabel!
    @IBOutlet var cameraImg:UIImageView!
    @IBOutlet var timeLbl:UILabel!
    @IBOutlet var selectedIconImgview:UIImageView!
    @IBOutlet var selectionImgView:UIImageView!
    @IBOutlet var statusImg:UIImageView!

}

