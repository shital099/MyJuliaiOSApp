//
//  HomeViewController.swift
//  My-Julia
//
//  Created by GCO on 4/11/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

protocol SideMenuControllerDelegate {
    func menuItemSelected(index: NSInteger, section:NSInteger)
}

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var modulesArray:NSMutableArray = []
    
    let reuseIdentifier = "CellIdentifier"
    var drawer = TKSideDrawer()
    var delegate:MenuViewController!
    var homeMenu:SideDrawerMenu!
    var homeIndex:Int!
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        //apply application theme on screen
        if !AppTheme.sharedInstance.isbackgroundColor {
            CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        }
        
        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()

        if IS_IPHONE {
          //  drawer = (self.menuContainerViewController.leftMenuViewController as! MenuViewController).drawer
            self.delegate =  self.menuContainerViewController.leftMenuViewController as! MenuViewController?
        }
        else {
           // drawer = ((self.splitViewController?.viewControllers[0] as? MenuViewController)?.drawer)!
            self.delegate =  self.splitViewController?.viewControllers.first as! MenuViewController?
        }
        
        //Fetch all module list from server
        modulesArray = self.delegate.fetchModuleListFromDB().mutableCopy() as! NSMutableArray
        
        //Remove home menu from section
        self.removeHomeModuleFromList()
    }
    
    func fetchModuleListFromDB() -> NSArray {
        
        //Add First section - User related module data
        let section1:TKSideDrawerSection = drawer.addSection(withTitle: "MY ITEMS")
        let section2:TKSideDrawerSection = drawer.addSection(withTitle: "EVENT GUIDE")
        
        //Fetch data from Sqlite database
        let listArray : [Modules] = DBManager.sharedInstance.fetchModulesDataFromDB() as! [Modules]
        
        for data in listArray {
            
            let sideDrawerItem: SideDrawerMenu = SideDrawerMenu().addItemWithTitle(titleStr: data.name)
            //sideDrawerItem.moduleIndex = data.index
            sideDrawerItem.smallIconImage = data.sIconUrl
            sideDrawerItem.largeIconImage = data.lIconUrl
            sideDrawerItem.isCustomMenu = data.isCustomModule
            sideDrawerItem.fontName = AppTheme.sharedInstance.menuFontName
            sideDrawerItem.fontStyle = AppTheme.sharedInstance.menuFontStyle
            sideDrawerItem.fontSize = AppTheme.sharedInstance.menuFontSize
            sideDrawerItem.textColor = AppTheme.sharedInstance.menuTextColor
            sideDrawerItem.moduleId = data.moduleId
            sideDrawerItem.customModuleContent = data.moduleContent
            
            if data.isUserRelated == true {
                section1.addItem(sideDrawerItem)
                
                //Check My schedule, reminder and my notes menu added or not
                let viewController = CommonModel.sharedInstance.fetchViewControllerObject(moduleId: sideDrawerItem.moduleId)
                if viewController is AgendaViewController {
                    isMySchedulesPresent = true
                }
            }
            else {
                section2.addItem(sideDrawerItem)
                
                //Check Agenda menu added or not
                let viewController = CommonModel.sharedInstance.fetchViewControllerObject(moduleId: sideDrawerItem.moduleId)
                if viewController is AgendaViewController {
                    isAgendaPresent = true
                }
            }
        }
        return  self.drawer.sections! as NSArray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func removeHomeModuleFromList()  {
        
        let predicate:NSPredicate = NSPredicate(format: "ClassName CONTAINS[c] %@", "HomeViewController")
        let filteredArray = ModulesID.sharedInstance.ModuleIDsListArray.filter { predicate.evaluate(with: $0) };
        
        if filteredArray.count != 0 {
            let dict = filteredArray.first
            
            var pred:NSPredicate = NSPredicate(format: "items.moduleId CONTAINS[c] %@", (dict?["ModuleID"])!)
            let array = modulesArray.filter { pred.evaluate(with: $0) };
            
            if array.count != 0 {
                
                let sections = array.first as! TKSideDrawerSection

                pred = NSPredicate(format: "moduleId CONTAINS[c] %@", (dict?["ModuleID"])!)
                let arr = sections.items.filter { pred.evaluate(with: $0) };
                if arr.count != 0 {
                    let item = arr.first as! SideDrawerMenu
                    sections.removeItem(item)
                }
                
                let index = modulesArray.index(of: sections)
                modulesArray.replaceObject(at: index, with: sections)
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
    
    // MARK: - Navigation UIBarButtonItems
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
    
    // MARK: - UICollectionViewDataSource
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return modulesArray.count
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let sideSection = modulesArray[section] as! TKSideDrawerSection
        
        if section == 0 {
           return sideSection.items.count
        }
        
        return sideSection.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        var headerView = HomeCollectionHeaderView()
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "HomeCollectionHeaderView",
                                                                             for: indexPath) as! HomeCollectionHeaderView
            let section = modulesArray[indexPath.section] as! TKSideDrawerSection
            headerView.headerTitleLbl?.text = section.title
        default:
            //4
            assert(false, "Unexpected element kind")
        }
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width / 3 , height:130.0)
        
//        var cellSize:CGSize
//
//        if IS_IPHONE         {
//            cellSize = CGSize(width: 100 , height:130.0)
//        }
//        else {
//            cellSize = CGSize(width: 130 , height:130.0)
//        }

    //    return cellSize;
    }

    //3
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        // cell.backgroundColor = UIColor.black
        
        let section = modulesArray[indexPath.section] as! TKSideDrawerSection
        var item: SideDrawerMenu
        
        if indexPath.section == 0 {
          item  = section.items[indexPath.row] as! SideDrawerMenu
        }
        else {
           item = section.items[indexPath.row] as! SideDrawerMenu
        }
        
        cell.titleLbl?.text = item.moduleTitle
        
        if item.isIconStyleColor == true {
            cell.iconImage?.backgroundColor = item.iconColor
            cell.iconImage?.image = nil
        }
        else {
            cell.iconImage?.sd_setImage(with: NSURL(string:item.largeIconImage as String)! as URL, placeholderImage: nil)
            cell.iconImage?.backgroundColor = nil
        }

        cell.gridImage?.backgroundColor = AppTheme.sharedInstance.backgroundColor.getDarkerColor()
        cell.gridImage?.layer.cornerRadius = 5.0 //(cell.gridImage?.frame.height)!/2
//        cell.gridImage?.layer.borderWidth = 1.0

        cell.titleLbl?.textColor = .white
        
//        cell.backgroundImage?.layer.borderColor = CventRGB.cgColor
//        cell.backgroundImage?.layer.masksToBounds = false
//        cell.backgroundImage?.layer.cornerRadius = (cell.backgroundImage?.frame.height)!/2
//        cell.backgroundImage?.layer.borderWidth = 1.0
//        cell.backgroundImage?.backgroundColor = AppTheme.sharedInstance.backgroundColor

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            self.delegate.menuItemSelected(index: indexPath.row, section: indexPath.section)
        }
        else {
            if self.homeIndex > indexPath.row {
                self.delegate.menuItemSelected(index: indexPath.row, section: indexPath.section)
            }
            else {
                self.delegate.menuItemSelected(index: indexPath.row+1, section: indexPath.section)
            }
        }
        return
    }
}


//#prama Custom cell class

class CustomCell: UICollectionViewCell {

    @IBOutlet var titleLbl:UILabel?
    @IBOutlet var iconImage:UIImageView?
    @IBOutlet var backgroundImage:UIImageView?
    @IBOutlet var gridImage:UIImageView?
}

class HomeCollectionHeaderView: UICollectionReusableView {
    @IBOutlet var headerTitleLbl:UILabel?
}
