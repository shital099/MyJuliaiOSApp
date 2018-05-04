//
//  TermsAndConditionsViewController.swift
//  My-Julia
//
//  Created by GCO on 13/02/2018.
//  Copyright © 2018 GCO. All rights reserved.
//

import UIKit

class TermsAndConditionsViewController: UIViewController {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false

        // Fetch terms and conditions content from server
        self.fetchContentFromServer()

        /*** Auto Layout ***/

        /*let string = "<p><strong>I Accept all the terms and conditions of the event</strong></p><p><strong></strong>As a condition to using Services, you are required to open an account with 500px and select a password and username, and to provide registration information. The registration information you provide must be accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your access to the Services, by either terminating your email access or your account.</p><p style=\"box-sizing:border-box;margin-top:1.4em;padding:0px;font-size:14px;line-height:1.5em;color:#525558;text-rendering:optimizeLegibility;font-family:'Helvetica Neue', HelveticaNeue, Helvetica, Arial, sans-serif;letter-spacing:-0.14px;background-color:#f7f8fa;\">You may not use as a username the name of another person or entity or that is not lawfully available for use, a name or trade mark that is subject to any rights of another person or entity other than you without appropriate authorization, or a name that is otherwise offensive, vulgar or obscene.</p><p style=\"box-sizing:border-box;margin-top:1.4em;padding:0px;font-size:14px;line-height:1.5em;color:#525558;text-rendering:optimizeLegibility;font-family:'Helvetica Neue', HelveticaNeue, Helvetica, Arial, sans-serif;letter-spacing:-0.14px;background-color:#f7f8fa;\">You are responsible for maintaining the confidentiality of your password and are solely responsible for all activities resulting from the use of your password and conducted through your 500px account.</p><p style=\"box-sizing:border-box;margin-top:1.4em;padding:0px;font-size:14px;line-height:1.5em;color:#525558;text-rendering:optimizeLegibility;font-family:'Helvetica Neue', HelveticaNeue, Helvetica, Arial, sans-serif;letter-spacing:-0.14px;background-color:#f7f8fa;\">Services are available authorized representatives of legal entities and to individuals who are either (i) at least 18 years old to access the Marketplace or to register for Premium Accounts, or (ii) at least 14 years old, and who are authorized to access the Site by a parent or legal guardian. If you have authorized a minor to use the Site, you are responsible for the online conduct of such minor, and the consequences of any misuse of the Site by the minor. Parents and legal guardians are warned that the Site does display Visual Content containing nudity and violence that may be offensive to some.</p><p style=\"box-sizing:border-box;margin-top:1.4em;padding:0px;font-size:14px;line-height:1.5em;color:#525558;text-rendering:optimizeLegibility;font-family:'Helvetica Neue', HelveticaNeue, Helvetica, Arial, sans-serif;letter-spacing:-0.14px;background-color:#f7f8fa;\">The Services are for use by a) individuals who own Visual Content; b) entities that represent owners of Visual Content including but not limited to galleries, agents, representatives, distributors other market intermediaries; and c) individuals and entities seeking to license Visual Content. We are currently not accepting illustration and graphic design content to upload on the Site. If you are the owner of the Visual Content, but not the creator, you are not allowed to upload content for the purposes of self advertising.</p>"
        if let htmlData = string.data(using: String.Encoding.unicode) {
            do {
                let attributedText = try NSAttributedString(data: htmlData, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
                self.contentLabel.attributedText = attributedText
            } catch let e as NSError {
                print("Couldn't translate \(e.localizedDescription) ")
            }
        }*/
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

    // MARK: - UIButton Action Methods

    @IBAction func onClickOfCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onClickOfIAcceptButton() {

    }

    // MARK: - Webservice Methods

    func fetchContentFromServer() {

        NetworkingHelper.getRequestFromUrl(name:Get_TermsAndCondition_Url, urlString: Get_TermsAndCondition_Url, callback: { response in
            print("\n Terms and conditions Details : ",response)

            if response is NSArray {
                let array = response as! NSArray
                if array.count != 0 {
                    let dict = array[0] as! NSDictionary
                    let content = DBManager.sharedInstance.isNullString(str: dict.value(forKey:"TermsCondition") as Any)
                    self.contentLabel.attributedText =  CommonModel.sharedInstance.stringFromHtml(string: content)
                   // self.contentText.attributedText = CommonModel.sharedInstance.stringFromHtml(string: content)

                    self.scrollView.bounces = false
                    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: self.contentLabel.frame.size.height + 100)

                }
            }
        }, errorBack: { error in
        })
    }
}
