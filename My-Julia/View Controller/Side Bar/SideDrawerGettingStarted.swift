//
//  SideDrawerGettingStarted.swift
//  TelerikUIExamplesInSwift
//
//  Copyright (c) 2015 Telerik. All rights reserved.
//

import UIKit

// >> drawer-attached-swift
class SideDrawerGettingStarted: UIViewController, TKSideDrawerDelegate {

    let sideDrawerView = TKSideDrawerView()
    let navItem = UINavigationItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true;
        
        self.sideDrawerView.frame = self.view.bounds
        self.view.addSubview(sideDrawerView)
        
        let mainView = sideDrawerView.mainView
        
        let backgroundView = UIImageView(frame: mainView.bounds)
        backgroundView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
        backgroundView.image = UIImage(named: "sdk-examples-bg")
        mainView.addSubview(backgroundView)
        
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: mainView.bounds.size.width, height: 64))
        navigationBar.autoresizingMask = UIViewAutoresizing.flexibleWidth
        let showSideDrawerButton = UIBarButtonItem(image: UIImage(named: "menu"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(SideDrawerGettingStarted.showSideDrawer))
        navItem.leftBarButtonItem = showSideDrawerButton
        navigationBar.items = [navItem]
        mainView.addSubview(navigationBar)
        
        let sideDrawer = sideDrawerView.sideDrawers[0]
        sideDrawer.delegate = self
        sideDrawer.transition = TKSideDrawerTransitionType.push
        sideDrawer.headerView = SideDrawerHeaderView(addButton: true, target: self, selector: #selector(SideDrawerGettingStarted.dismissSideDrawer))
        
        // >> drawer-style-swift
        sideDrawer.style.headerHeight = 64
        sideDrawer.style.shadowMode = TKSideDrawerShadowMode.hostview
        sideDrawer.style.shadowOffset = CGSize(width: -2, height: -0.5)
        sideDrawer.style.shadowRadius = 5
        // << drawer-style-swift
        
        var section = sideDrawer.addSection(withTitle: "MY ITEMS")
        _ = section?.addItem(withTitle: "Social")
        _ = section?.addItem(withTitle: "Promotions")
        
        _ = section = sideDrawer.addSection(withTitle: "EVENT GUIDE")
        _ = section?.addItem(withTitle: "Important")
        _ = section?.addItem(withTitle: "Starred")
        _ = section?.addItem(withTitle: "Sent Mail")
        _ = section?.addItem(withTitle: "Drafts")
        
//        let vc = storyboard?.instantiateViewController(withIdentifier: "SplitViewController") as! SplitViewController
//        mainView.addSubview(vc.view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.sideDrawerView.frame = self.view.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let navController = self.navigationController {
            if navController.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) {
                self.navigationController!.interactivePopGestureRecognizer!.isEnabled = true
            }
        }
    }
    
    
    @objc func showSideDrawer() {
        sideDrawerView.sideDrawers[0].show()
    }
    
    @objc func dismissSideDrawer() {
        sideDrawerView.sideDrawers[0].dismiss()
    }
    // << drawer-attached-swift
    
    // >> drawer-update-section-swift
    func sideDrawer(_ sideDrawer: TKSideDrawer!, updateVisualsForSection sectionIndex: Int) {
        let section = sideDrawer.sections[sectionIndex] as! TKSideDrawerSection
        section.style.contentInsets = UIEdgeInsetsMake(0, -15, 0, 0)
    }
    // << drawer-update-section-swift
    
    // >> drawer-update-swift
    func sideDrawer(_ sideDrawer: TKSideDrawer!, updateVisualsForItemAt indexPath: IndexPath!) {
        let currentItem = (sideDrawer.sections[indexPath.section] as! TKSideDrawerSection).items[indexPath.item] as! TKSideDrawerItem
        currentItem.style.contentInsets = UIEdgeInsetsMake(0, -10, 0, 0)
        currentItem.style.separatorColor = TKSolidFill(color: UIColor.clear)
    }
    // << drawer-update-swift
    
    // >> drawer-did-select-swift
    func sideDrawer(_ sideDrawer: TKSideDrawer!, didSelectItemAt indexPath: IndexPath!) {
        NSLog("Selected item in section: %ld at index: %ld ", indexPath.section, indexPath.row)
    }
    // << drawer-did-select-swift
}
