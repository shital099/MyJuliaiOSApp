//
//  SideDrawerHeaderView.swift
//  TelerikUIExamplesInSwift
//
//  Copyright (c) 2015 Telerik. All rights reserved.
//


class SideDrawerHeaderView: UIView {
    
    let sideDrawerHeader = TKSideDrawerHeader(title: "Navigation Menu")
    
    convenience init (addButton: Bool, target: AnyObject?,selector: Selector?) {
        self.init()
        sideDrawerHeader.contentInsets = UIEdgeInsetsMake(-15, 0, 0, 0)
        if addButton {
            let button = UIButton(type:UIButtonType.system)
            button.setImage(UIImage(named: "menu"), for: UIControlState())
            button.addTarget(target, action: selector!, for: UIControlEvents.touchUpInside)
            sideDrawerHeader.actionButton = button
            sideDrawerHeader.contentInsets = UIEdgeInsetsMake(-15, -20, 0, 0)
            sideDrawerHeader.buttonPosition = TKSideDrawerHeaderButtonPosition.left
        }
        
        //self.addSubview(sideDrawerHeader)
    }
    
    override func layoutSubviews() {
        sideDrawerHeader.frame = self.bounds
    }
}
