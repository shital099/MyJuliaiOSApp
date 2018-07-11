//
//  ChatContactsViewController.swift
//  My-Julia
//
//  Created by GCO on 8/17/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class ChatContactsViewController: UIViewController, headerDelegate, UISearchBarDelegate, UISearchResultsUpdating{

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var tableView: NameListTableView!
    @IBOutlet weak var createBtn: UIBarButtonItem!
    @IBOutlet weak var searchBtn: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!

    var searchController : UISearchController!
    private var mySearchBar: UISearchBar!
    private var myLabel : UILabel!

    var headerView: HeaderView!
    var groupId : String? = nil
    
    var filtered:[ChatGroupModel] = []
    var listArray:[ChatGroupModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Select Contact"
        
        //Initially disable add group button
        self.navigationItem.rightBarButtonItem?.isEnabled = false

        // Setup the Search Controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true;
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.barStyle = .default
     //   self.searchController.searchBar.backgroundColor = .clear
        self.searchController.searchBar.showsCancelButton = true
        //self.searchController.searchBar.tintColor = UIColor.red
      //  self.searchController.searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
       // self.view.addSubview(self.searchController.searchBar)
//
//        self.searchController.searchBar.layer.position = CGPoint(x: self.view.bounds.width/2, y: 20)
        
        // Setup the Scope Bar
       // tableView.tableHeaderView = searchController.searchBar
        
        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()
        tableView.tintColor = AppTheme.sharedInstance.backgroundColor.darker(by: 40)!
            
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableView)
        
        headerView = HeaderView()
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0)
        headerView.delegate = self
        tableView.tableHeaderView = headerView
        
        self.tableView.setDelegates()
        self.tableView.isGroupTable = false
        
        self.tableView.block = { (seleArr) -> Void in
            // Handle success response
            self.headerView.headerDataArr = seleArr
            self.tableView.beginUpdates()
            self.tableView.tableHeaderView = self.headerView
            self.tableView.endUpdates()
        }

        //New Group create button tap
        self.tableView.newGropBlock = { () -> Void in
            
            self.title = "New group"
            
            //Enable add group button
           // self.navigationItem.rightBarButtonItem = self.createBtn
            self.navigationItem.rightBarButtonItem?.isEnabled = true

            // Handle success response
            self.tableView.isGroupTable = true
            self.tableView.reloadData()
        }

        //New Chat Started
        self.tableView.newContactSelectBlock = { (model) -> Void in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            print("Tag  :",self.view.tag)
            print("from id ",(model as! ChatGroupModel).name)
            vc.chatGroupModel = model as! ChatGroupModel
            vc.isFromContactList = true

//            let cModel = ChatGroupModel()
//            cModel.groupId = personModel.personId
//            cModel.fromId = EventData.sharedInstance.attendeeId
//            cModel.name = personModel.name
//            cModel.iconUrl = personModel.iconUrl
//            cModel.isGroupChat = false
//            vc.chatGroupModel = cModel
            print("from id ",vc.chatGroupModel.fromId)
            print("to id ",vc.chatGroupModel.groupId)

            self.navigationController?.pushViewController(vc, animated: true)
        }

        //Fetch user list
       // self.fetchAllContactsList()
        //Fetch data from Sqlite database
       // tableView.allDataArr = NSMutableArray(array: DBManager.sharedInstance.fetchAllContactDataFromDB() as! [ChatGroupModel])

        //Fetch data from Sqlite database
        self.listArray = DBManager.sharedInstance.fetchAllContactDataFromDB() as! [ChatGroupModel]
        tableView.allDataArr = NSMutableArray(array: self.listArray)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.searchBar.resignFirstResponder()
    }
    
    func addSearchbarOnNavigation() {
        
        // make UISearchBar instance
        mySearchBar = UISearchBar()
        mySearchBar.delegate = self
        mySearchBar.frame = CGRect(x: 0, y: 0, width: 300, height: 80)
        mySearchBar.layer.position = CGPoint(x: self.view.bounds.width/2, y: 0)
        
        // add shadow
        mySearchBar.layer.shadowColor = UIColor.black.cgColor
        mySearchBar.layer.shadowOpacity = 0.5
        mySearchBar.layer.masksToBounds = false
        
        // hide cancel button
        mySearchBar.showsCancelButton = true
        
        // hide bookmark button
        mySearchBar.showsBookmarkButton = false
        
        // set Default bar status.
        mySearchBar.searchBarStyle = UISearchBarStyle.default
        
        // set title
        mySearchBar.prompt = "Title"
        
        // set placeholder
        mySearchBar.placeholder = "Input text"
        
        // change the color of cursol and cancel button.
        mySearchBar.tintColor = UIColor.red
        
        // hide the search result.
        mySearchBar.showsSearchResultsButton = false
        
        // add searchBar to the view.
        self.view.addSubview(mySearchBar)
        
//        // make UITextField
//        myLabel = UILabel(frame:CGRect(x: 0, y: 0, width: 200, height: 30))
//        myLabel.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
//        myLabel.text = ""
//        myLabel.layer.borderWidth = 1.0
//        myLabel.layer.borderColor = UIColor.gray.cgColor
//        myLabel.layer.cornerRadius = 10.0
//
//        // add the label to the view.
//        self.view.addSubview(myLabel)
//        self.navigationController?.navigationBar.addSubview(myLabel)
    }
    
    // called whenever text is changed.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      //  myLabel.text = searchText
        self.tableView.isSearchTable = true
        filterContentForSearchText(searchText)
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
        
        self.filtered = self.listArray.filter({( model : ChatGroupModel) -> Bool in
            return model.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.allDataArr = NSMutableArray(array: self.filtered)
        print("Search table : ",tableView.allDataArr.count)
//        if filtered.count != 0 {
//            tableView.allDataArr = NSMutableArray(array: self.filtered)
//        }
//        else {
//            tableView.allDataArr = NSMutableArray(array: self.listArray)
//        }
        self.tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // self.navigationItem.leftBarButtonItem = nil
        // self.searchController.searchBar.removeFromSuperview()
        self.tableView.isSearchTable = false
        self.searchBar.text = ""
        
        tableView.allDataArr = NSMutableArray(array: self.listArray)
        self.tableView.reloadData()
        self.searchBar.resignFirstResponder()
    }

    // MARK: - Navigation

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - headerDelegate methods
    
    func btnActionDelegate(_ arr: NSMutableArray!) {
        self.headerView.headerDataArr = arr
        self.tableView.btnActionArr = arr as! [Any]!
        self.tableView.beginUpdates()
        self.tableView.tableHeaderView = self.headerView
        self.tableView.endUpdates()
    }
    
    // MARK: - Button Action methods

    @IBAction func onClickOfCreateBtn(sender : AnyObject) {
        
        if self.headerView.headerDataArr == nil {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: Empty_Group_Member_Message, vc: self)
            return
        }
        else if self.headerView.headerDataArr.count == 0 {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: Empty_Group_Member_Message, vc: self)
            return
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateGroupViewController") as! CreateGroupViewController
        vc.listArray = self.headerView.headerDataArr
        self.navigationController?.pushViewController(vc, animated: true)

//        //Add member in already created group
//        if self.groupId != nil {
//            self.addMembersInGroup(groupId: "")
//            return
//        }
    }
    
    @IBAction func onClickOfSearchBtn(sender : AnyObject) {
        //self.navigationItem.titleView = searchController.searchBar;
       
        //let leftNavBarButton = UIBarButtonItem(customView:self.searchController.searchBar)
        //self.navigationItem.leftBarButtonItem = leftNavBarButton
        ///self.searchController.searchBar.frame = CGRect(x:0,y :20, width:self.view.frame.width,height:self.view.frame.height)
        
        //self.searchController.searchBar.frame = (self.navigationController?.navigationBar.frame)!
        //self.navigationController?.navigationBar.addSubview(self.searchController.searchBar)
        
        // add searchBar to the view.
        self.navigationController?.navigationBar.addSubview(self.searchController.searchBar)

        //self.addSearchbarOnNavigation()
    }
    
    
    // MARK: - Webservice methods

    func addMembersInGroup(groupId : String) {
        
        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()
        
        var paramArr : [Any] = []
        for item in self.headerView.headerDataArr {
            let model = item as! ChatGroupModel
            paramArr.append(model.groupId)
        }
        
        let paramDict = ["GroupChatId":self.groupId ?? "", "AttendeeId":paramArr] as [String : Any]
        
        NetworkingHelper.postData(urlString:Chat_Add_Group_Members, param:paramDict as AnyObject, withHeader: false, isAlertShow: true, controller:self, callback: { [weak self] response in
            //dissmiss Indicator
            CommonModel.sharedInstance.dissmissActitvityIndicator()
            
            let responseCode = Int(response.value(forKey: "responseCode") as! String)
            if responseCode == 0 {
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }, errorBack: { error in
        })
    }

}
