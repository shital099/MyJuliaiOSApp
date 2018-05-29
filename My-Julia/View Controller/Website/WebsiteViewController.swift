//
//  WebsiteViewController.swift
//  My-Julia
//
//  Created by GCO on 7/6/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class WebsiteViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var webview: UIWebView!

    var model : WebsiteModel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()
        
        //        if IS_IPHONE {
        //            self.setupMenuBarButtonItems()
        //        }

        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)

        webview.delegate = self
        
        //Fetch data from Sqlite database
       // model = DBManager.sharedInstance.fetchWebsiteDataFromDB()
       // self.loadUrlInWebview()
        
        self.getWebsiteData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        CommonModel.sharedInstance.dissmissActitvityIndicator()
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
            masterVC =  self.menuContainerViewController.leftMenuViewController as! MenuViewController?
        }
        else {
            masterVC = self.splitViewController?.viewControllers.first
        }
        
        if ((masterVC as? MenuViewController) != nil) {
            (masterVC as! MenuViewController).toggleLeftSplitMenuController()
        }
    }
    
    
//    //MARK:- WebService Methods

    func getWebsiteData() {

        let urlStr = Get_AllModuleDetails_url.appendingFormat("Flag=%@",Website_List_url)
        NetworkingHelper.getRequestFromUrl(name:Website_List_url,  urlString: urlStr, callback: { [weak self] response in
            self?.model = DBManager.sharedInstance.fetchWebsiteDataFromDB()
            self?.loadUrlInWebview()
        }, errorBack: { error in
            NSLog("error : %@", error)
        })
    }
    
    func loadUrlInWebview()  {
        
        let urlName : String = DBManager.sharedInstance.isNullString(str: model.websiteUrl)
        var url : URL? = nil
        if urlName.lowercased().hasPrefix("http://") || urlName.lowercased().hasPrefix("https://") {
            url = URL (string: urlName)! as URL
        }
        else {
            if URL (string: String(format:"http://%@", urlName)) != nil {
                url = URL (string: String(format:"http://%@", urlName))!
            }
        }
        
        if url != nil {
            CommonModel.sharedInstance.showActitvityIndicator()
            let requestObj = URLRequest(url: url! as URL)

            self.webview.loadRequest(requestObj)
        }
    }

    //MARK:- Webview Delegate Methods

    func webViewDidFinishLoad(_ webView: UIWebView) {
        CommonModel.sharedInstance.dissmissActitvityIndicator()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("Failed load url ",error)
        CommonModel.sharedInstance.dissmissActitvityIndicator()
    }
}
