//
//  GroupDetailViewController.swift
//  EventApp
//
//  Created by GCO on 8/18/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class GroupDetailViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var groupIcon: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupNameLbl: UILabel!
    @IBOutlet weak var adminNameLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!

    var chatGroupModel: ChatGroupModel!
    var listArray:NSMutableArray = []
    var groupsIsStr: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = self.chatGroupModel.name
        

        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableView)
        
        //Check looged user is admin then only allowed attendee to add in group
        if self.chatGroupModel.groupCreatedUserId != AttendeeInfo.sharedInstance.attendeeId {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if self.listArray.count != 0 {
            self.listArray.removeAllObjects()
        }
        
        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()

        //Fetch all group members
        self.fetchAllGroupMembers()
    }

    func showGroupInfo() {

        SDImageCache.shared().removeImage(forKey: self.chatGroupModel.iconUrl, withCompletion: nil)

        self.groupNameLbl.text = self.chatGroupModel.name
       // self.groupIcon.sd_setImage(with: URL(string:self.chatGroupModel.iconUrl), placeholderImage: #imageLiteral(resourceName: "group_icon"))

        //Show group icon image
        self.loadGroupIcon()

        //Show Created user name
        let predicate:NSPredicate = NSPredicate(format: "fromId CONTAINS[c] %@", self.chatGroupModel.groupCreatedUserId)
        let filteredArray = self.listArray.filter { predicate.evaluate(with: $0) };
        //If record found
        if filteredArray.count != 0  {
            let model = filteredArray[0] as! ChatGroupModel
            let dateStr = CommonModel.sharedInstance.getChatGroupCreatedDate(dateStr: self.chatGroupModel.dateStr)

            if model.fromId == EventData.sharedInstance.attendeeId {
                self.adminNameLbl.text = String(format:"Created by you, %@",dateStr)
            }
            else {
                self.adminNameLbl.text = String(format:"Created by %@, %@",model.name, dateStr)
            }
        }
    }

    func loadGroupIcon()  {

        self.groupIcon.sd_setImage(with: URL(string:self.chatGroupModel.iconUrl), placeholderImage: #imageLiteral(resourceName: "no_group_icon"), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            // Perform operation.
            // self.groupIcon.contentMode = UIViewContentMode.scaleAspectFill
        })

        self.groupIcon.clipsToBounds = true
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

    // MARK: - Delegate methods
    func updateGroupName(groupName : String, groupIcon : String) {

        self.title = groupName

        self.chatGroupModel.name = groupName
        //Show updated group name
        self.groupNameLbl.text = groupName
        self.chatGroupModel.iconUrl = groupIcon

        //Show group icon image
        self.loadGroupIcon()
    }

    // MARK: - Button Action methods
    
    @IBAction func onClickOfAddMemberBtn(sender : AnyObject) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddMemberViewController") as! AddMemberViewController
        vc.chatGroupModel = self.chatGroupModel
        vc.groupsIsStr = self.groupsIsStr
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func onClickOfEditBtn(sender : AnyObject) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditGroupDetailsViewController") as! EditGroupDetailsViewController
        vc.chatGroupModel = self.chatGroupModel
        vc.isIconEdit = false
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: false)

        //self.navigationController?.pushViewController(vc, animated: true)
       // present(vc, animated: false, completion: nil)

      //  self.present(vc, animated: true, completion: nil)
       // self.showControllerWithAnimation(vc: vc)
    }

    @IBAction func onClickOfGroupIconBtn(sender : AnyObject) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditGroupDetailsViewController") as! EditGroupDetailsViewController
        vc.chatGroupModel = self.chatGroupModel
        vc.isIconEdit = true
        self.navigationController?.pushViewController(vc, animated: false)
       // self.showControllerWithAnimation(vc: vc)
    }

    func showControllerWithAnimation(vc : EditGroupDetailsViewController)  {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionReveal
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
        //        view.window!.layer.add(transition, forKey: kCATransition)
        view!.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(vc, animated: false)
    }

    // MARK: - Web Service methods
    
    func fetchAllGroupMembers() {
        
        NetworkingHelper.getRequestFromUrl(name:Chat_Get_Group_Members,  urlString:Chat_Get_Group_Members.appending(self.chatGroupModel.groupId), callback: { response in
            CommonModel.sharedInstance.dissmissActitvityIndicator()

            if response is Array<Any> {
                self.parseMemberData(response: response)
            }

            //Show group details on view
            self.showGroupInfo()
        }, errorBack: { error in
            NSLog("error : %@", error)
            CommonModel.sharedInstance.dissmissActitvityIndicator()
        })
    }
    
    func parseMemberData(response: AnyObject) {
        
        groupsIsStr = ""
        
        //Parse chat contacts
        for item in response as! NSArray {
            let  dict = item as! NSDictionary
            let model = ChatGroupModel()
            model.groupId = dict.value(forKey: "AttendeeId") as! String!
            model.fromId = dict.value(forKey: "AttendeeId") as! String!
            model.name = dict.value(forKey: "Name") as! String
            let path = dict.value(forKey: "ImgPath")
            model.iconUrl = DBManager.sharedInstance.appendImagePath(path:path ?? "")
            model.isGroupChat = false
            self.listArray.add(model)
            
            //While adding new member in - Remove groups member from list
            if groupsIsStr != "" {
                groupsIsStr = groupsIsStr.appending(", ")
            }
            groupsIsStr = groupsIsStr.appendingFormat("'%@'", model.fromId)
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - UITableView Delegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! GroupInfoCustomCell
        cell.backgroundColor = cell.contentView.backgroundColor;

        var model : ChatGroupModel
        
        model = self.listArray[indexPath.row] as! ChatGroupModel
        cell.nameLabel?.text = model.name
        cell.imageview.image = #imageLiteral(resourceName: "user")

        if self.chatGroupModel.groupCreatedUserId == model.fromId {
            cell.statusLabel?.text = "Admin"
            //self.adminNameLbl.text = String(format:"Created by you",CommonModel.sharedInstance.getChatGroupCreatedDate(dateStr: self.chatGroupModel.dateStr))
        }
        else {
            cell.statusLabel?.text = ""
           // self.adminNameLbl.text = String(format:"Created by %@",model.name,CommonModel.sharedInstance.getChatGroupCreatedDate(dateStr: self.chatGroupModel.dateStr))
        }
        
        if !model.iconUrl.isEmpty {
            cell.imageview.sd_setImage(with: URL(string:model.iconUrl), placeholderImage: #imageLiteral(resourceName: "user"))
            cell.imageview?.layer.cornerRadius = cell.imageview.frame.size.height/2
            cell.imageview.contentMode = UIViewContentMode.scaleAspectFill
            cell.imageview.clipsToBounds = true
            cell.imageview.layer.borderColor = UIColor.gray.cgColor
            cell.imageview.layer.borderWidth = 1.0
        }

        return cell
    }
}

// MARK: - Custom Cell Classes

class GroupInfoCustomCell: UITableViewCell {
    
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var imageview:UIImageView!
    @IBOutlet var statusLabel:UILabel!
}


