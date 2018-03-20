//
//  AttachmentDetailsViewController.swift
//  My-Julia
//
//  Created by GCO on 18/08/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class AttachmentDetailsViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!

    var model : EmailModel!
    var attechmentUrl : String!
    var attechmentName : String!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.attechmentName
        

    }

    override func viewDidAppear(_ animated: Bool) {
        //  Load PDF from server
        let targetURL = NSURL(string:DBManager.sharedInstance.appendImagePath(path: self.attechmentUrl))! as URL
        let request = URLRequest(url: targetURL)
        webView.loadRequest(request)
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

    @IBAction func onClickOfDownloadBtn(sender : UIButton) {
        if let audioUrl = URL(string: self.attechmentUrl) {
            // create your document folder url
            let documentsUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            // your destination file url
            let destination = documentsUrl.appendingPathComponent(audioUrl.lastPathComponent)
            // check if it exists before downloading it
            if FileManager().fileExists(atPath: destination.path) {
                print("The file already exists at path")
            } else {
                //  if the file doesn't exist
                //  just download the data from your url
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) in
                    // after downloading your data you need to save it to your destination url
                    guard
                        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                        let mimeType = response?.mimeType, mimeType.hasPrefix("audio"),
                        let location = location, error == nil
                        else { return }
                    do {
                        try FileManager.default.moveItem(at: location, to: destination)
                        print("file saved")
                    } catch {
                        print(error)
                    }
                }).resume()
            }
        }
    }
}
