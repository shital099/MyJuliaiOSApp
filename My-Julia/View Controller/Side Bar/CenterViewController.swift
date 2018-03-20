//
//  CenterViewController.swift
//  EventApp
//
//  Created by GCO on 4/10/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class CenterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()
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

    // MARK: - Navigation UIBarButtonItems
    
    func setupMenuBarButtonItems() {
    
       // self.navigationItem.rightBarButtonItem = self.rightMenuBarButtonItem()
        
        if self.menuContainerViewController.menuState == MFSideMenuStateClosed && !((self.navigationController?.viewControllers.first?.isEqual(self))!) {
            self.navigationItem.leftBarButtonItem = self.leftMenuBarButtonItem()
        }
        else {
            self.navigationItem.leftBarButtonItem = self.leftMenuBarButtonItem()
        }
    } 

    func rightMenuBarButtonItem()-> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(self.leftSideMenuButtonPressed(sender:))) // action:#selector(Class.MethodName) for swift 3
    }
    
    func leftMenuBarButtonItem()-> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(self.leftSideMenuButtonPressed(sender:))) // action:#selector(Class.MethodName) for swift 3
    }

    
    // MARK: - Navigation UIBarButtonItems
    @objc func leftSideMenuButtonPressed(sender: UIBarButtonItem) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { 
            self.setupMenuBarButtonItems()
        }
    }

}
