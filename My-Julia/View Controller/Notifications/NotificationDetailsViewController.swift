//
//  NotificationDetailsViewController.swift
//  My-Julia
//
//  Created by GCO on 24/04/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class NotificationDetailsViewController: UIViewController {

    var nameStr: String?
    var messageStr: String?
    var timeStr: String?
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = nameStr
        msgLabel.text = messageStr
        timeLabel.text = timeStr
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
