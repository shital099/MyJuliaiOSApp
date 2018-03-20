//
//  SideDrawerMenu.swift
//  EventApp
//
//  Created by GCO on 4/11/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class SideDrawerMenu: TKSideDrawerItem {

  // Menu Drawer title used by the default header view.
    var moduleTitle: String!

    /**      Menu Drawer theme.      */
    var theme : AppTheme!
    
    /**      Menu Drawer icon.      */
    var smallIconImage: String!
    
    var largeIconImage:String!
    
    var textColor: UIColor = UIColor.darkGray
    var fontSize: Int = 16
    var fontName: String = "Helvetica"
    var fontStyle: String = "Normal"

   @objc var moduleId: String = ""
    var moduleIndex: Int = 0
 
    var iconStyle: String = ""

    var isIconStyleColor: Bool = false
    
    var iconColor: UIColor!
    
    var isCustomMenu: Bool = false
    
    var customModuleContent: String = ""

    var dataCount: Int = 0

    func addItemWithTitle(titleStr:String, smallIcon:UIImage, largeIcon:UIImage) -> SideDrawerMenu {
    
        moduleTitle = titleStr;
        
        return self;
    }
    
    func addItemWithTitle(titleStr:String) -> SideDrawerMenu {
        
        moduleTitle = titleStr;
        return self;
    }


}
 
