//
//  AddMemberViewController.swift
//  My-Julia
//
//  Created by GCO on 8/21/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class AddMemberViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    var chatGroupModel: ChatGroupModel!
    let searchController = UISearchController(searchResultsController: nil)
//    var listArray:NSMutableArray = []
    var filteredArr = [ChatGroupModel]()
    var listArray = [ChatGroupModel]()
    var groupsIsStr: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Add Member"

        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        // Setup the Scope Bar
        tableView.tableHeaderView = searchController.searchBar
        
        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableView)
                
        //Fetch data from Sqlite database
        self.listArray = DBManager.sharedInstance.fetchAddNewMemberContactsDataFromDB(ids:groupsIsStr ) as! [ChatGroupModel]
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
    
    // MARK: - Webservice Methods
    
    /*func fetchAllContactsList() {
        
        NetworkingHelper.getRequestFromUrl(name:Chat_All_Contact_List,  urlString:Chat_All_Contact_List.appending(EventData.sharedInstance.eventId), callback: { [weak self] response in
            print("Chat contact List :", response)
            if response is Array<Any> {
                self.parseChatData(response: response)
            }
        }, errorBack: { error in
            NSLog("error : %@", error)
        })
    }
    
    func parseChatData(response: AnyObject) {
        
        //Parse chat contacts
        for item in response as! NSArray {
            let  dict = item as! NSDictionary
            let model = ChatGroupModel()
            model.groupId = dict.value(forKey: "AttendeeId") as! String!
            model.fromId = dict.value(forKey: "AttendeeId") as! String!
            model.name = dict.value(forKey: "Name") as! String
            let path = dict.value(forKey: "ImgPath")
            if (path as? NSNull) == nil {
                model.iconUrl = BASE_URL.appending(path as! String)
            }
            model.isGroupChat = false
            self.listArray.append(model)
        }
        
        self.tableView.reloadData()
    }*/

    func addMembersInGroup(attendeId : String) {
        
        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()
        
        let paramArr : [Any] = [attendeId]
        let paramDict = ["GroupChatId":self.chatGroupModel.groupId ?? "", "AttendeeId":paramArr] as [String : Any]
        
        NetworkingHelper.postData(urlString:Chat_Add_Group_Members, param:paramDict as AnyObject, withHeader: false, isAlertShow: true, controller:self, callback: { [weak self] response in
            //dissmiss Indicator
            CommonModel.sharedInstance.dissmissActitvityIndicator()
            
            let responseCode = Int(response.value(forKey: "responseCode") as! String)
            if responseCode == 0 {
                self?.navigationController?.popViewController(animated: true)
            }
        }, errorBack: { error in
        })
    }

    
    // MARK: - UITableView DataSource Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return self.filteredArr.count
        }
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! AttendeesCustomCell
        cell.backgroundColor = cell.contentView.backgroundColor

        var model : ChatGroupModel
        
        if searchController.isActive && searchController.searchBar.text != "" {
            model = self.filteredArr[indexPath.row]
        } else {
            model = self.listArray[indexPath.row]
        }
        cell.nameLabel?.text = model.name
        
        if !model.iconUrl.isEmpty {
            cell.imageview.sd_setImage(with: URL(string:model.iconUrl), placeholderImage: #imageLiteral(resourceName: "user"))
            cell.imageview?.layer.cornerRadius = cell.imageview.frame.size.height/2
            cell.imageview.clipsToBounds = true
            cell.imageview.layer.borderColor = UIColor.gray.cgColor
            cell.imageview.layer.borderWidth = 1.0
        }

        return cell
    }
    
    // MARK:-  UITableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        var model : ChatGroupModel
        if searchController.isActive && searchController.searchBar.text != "" {
            model = self.filteredArr[indexPath.row]
        } else {
            model = self.listArray[indexPath.row] 
        }

        let message = String(format: "Add %@ to group?",model.name)
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{ (UIAlertAction)in
                print("User click Ok button")
                self.addMembersInGroup(attendeId: model.fromId)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler:{ (UIAlertAction)in
                alert.dismiss(animated: true, completion: nil)
            }))

            self.present(alert, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            let alert = UIAlertView()
            alert.title = ""
            alert.message = message
            alert.addButton(withTitle: "OK")
            alert.delegate = self
            alert.show()
        }
    }
    
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
    
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        
        self.filteredArr = listArray.filter({( candy : ChatGroupModel) -> Bool in
            return candy.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }

}
