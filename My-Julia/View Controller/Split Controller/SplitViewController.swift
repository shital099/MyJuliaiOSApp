//
//  SplitViewController.swift
//  EventApp
//
//  Created by GCO on 4/6/17.
//  Copyright © 2017 GCO. All rights reserved.
//    // test//


import UIKit

class SplitViewController: UISplitViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        let kMasterViewWidth:CGFloat = SPLIT_WIDTH;
        
        let masterViewController = self.viewControllers[0]
        let detailViewController = self.viewControllers[1]
        
        if (detailViewController.view.frame.origin.x > 0.0) {
            // Adjust the width of the master view
            var masterViewFrame: CGRect = masterViewController.view.frame;
            let deltaX = masterViewFrame.size.width - kMasterViewWidth;
            masterViewFrame.size.width -= deltaX;
            masterViewController.view.frame = masterViewFrame;
            
            // Adjust the width of the detail view
            var detailViewFrame : CGRect = detailViewController.view.frame;
            detailViewFrame.origin.x -= deltaX;
            detailViewFrame.size.width += deltaX;
            detailViewController.view.frame = detailViewFrame;
            
            masterViewController.view.setNeedsLayout()
            detailViewController.view.setNeedsLayout()
        }
    }
    
    //    @objc func showSideDrawer() {
    //        sideDrawerView.sideDrawers[0].show()
    //    }
    //
    //    @objc func dismissSideDrawer() {
    //        sideDrawerView.sideDrawers[0].dismiss()
    //    }
    //    // << drawer-attached-swift
    //
    //    // >> drawer-update-section-swift
    //    func sideDrawer(_ sideDrawer: TKSideDrawer!, updateVisualsForSection sectionIndex: Int) {
    //        let section = sideDrawer.sections[sectionIndex] as! TKSideDrawerSection
    //        section.style.contentInsets = UIEdgeInsetsMake(0, -15, 0, 0)
    //    }
    //    // << drawer-update-section-swift
    //
    //    // >> drawer-update-swift
    //    func sideDrawer(_ sideDrawer: TKSideDrawer!, updateVisualsForItemAt indexPath: IndexPath!) {
    //        let currentItem = (sideDrawer.sections[indexPath.section] as! TKSideDrawerSection).items[indexPath.item] as! TKSideDrawerItem
    //        currentItem.style.contentInsets = UIEdgeInsetsMake(0, -10, 0, 0)
    //        currentItem.style.separatorColor = TKSolidFill(color: UIColor.clear)
    //    }
    //    // << drawer-update-swift
    //
    //    // >> drawer-did-select-swift
    //    func sideDrawer(_ sideDrawer: TKSideDrawer!, didSelectItemAt indexPath: IndexPath!) {
    //        NSLog("Selected item in section: %ld at index: %ld ", indexPath.section, indexPath.row)
    //    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
