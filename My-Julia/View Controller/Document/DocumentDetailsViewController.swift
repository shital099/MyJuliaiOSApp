//
//  DocumentDetailsViewController.swift
//  My-Julia
//
//  Created by GCO on 7/10/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class DocumentDetailsViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var model : DocumentModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = model.title

        //Load PDF from resource
        
//        if let pdf = Bundle.main.url(forResource: model.pdfUrlStr, withExtension: "pdf", subdirectory: nil, localization: nil)  {
//            let req = URLRequest(url: pdf)
//            webView.loadRequest(req)
//        
//        }
        
        //Load PDF from server
        let targetURL = NSURL(string: model.pdfUrlStr )! // This value is force-unwrapped for the sake of a compact example, do not do this in your code
        var request = URLRequest(url: targetURL as URL)
        request.setValue("Basic ".appending(EventData.sharedInstance.auth_token), forHTTPHeaderField: "Authorization")
        webView.loadRequest(request)

        self.updateReadStatus()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation000000

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Webservice Methods

    func updateReadStatus()  {

        let urlStr = UpdateReadStatus.appendingFormat("flag=%@&Id=%@",Update_Documents_List,self.model.docId)
        NetworkingHelper.getRequestFromUrl(name:UpdateReadStatus,  urlString:urlStr, callback: { [weak self] response in

        }, errorBack: { error in
        })
    }

}
