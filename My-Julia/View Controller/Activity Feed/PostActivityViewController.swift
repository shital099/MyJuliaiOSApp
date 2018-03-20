//
//  PostActivityViewController.swift
//  EventApp
//
//  Created by GCO on 09/06/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class PostActivityViewController: UIViewController {

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var textField: UITextView!

    
    var capturedPhoto : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        capturedImageView.image = capturedPhoto
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostActivityViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Button Action Methods
    
    @IBAction func onClickOfPostButton(sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
        
        UIImageWriteToSavedPhotosAlbum(capturedPhoto, nil, nil, nil);
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    
}
