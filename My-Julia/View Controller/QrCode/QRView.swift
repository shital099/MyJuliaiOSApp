//
//  QRView.swift
//  My-Julia
//
//  Created by GCO on 01/08/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class QRView: UIView {

    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var attendeeNameLbl: UILabel!
    @IBOutlet weak var eventNameLbl: UILabel!
    @IBOutlet weak var eventDateLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!

    override func draw(_ rect: CGRect) {

        self.layoutIfNeeded()

        attendeeNameLbl.text = AttendeeInfo.sharedInstance.attendeeName

        if !AttendeeInfo.sharedInstance.qr_code.isEmpty {
            qrImageView.sd_setImage(with: URL(string:AttendeeInfo.sharedInstance.qr_code), placeholderImage: nil)
        }

        self.attendeeNameLbl.text = AttendeeInfo.sharedInstance.attendeeName
        
        let event = EventData.sharedInstance
        self.eventNameLbl.text = event.eventName
        self.eventNameLbl.text = event.eventVenue
        
        if event.eventStartDate != "" {
            self.eventDateLbl.text = CommonModel.sharedInstance.getEventDate(dateStr: event.eventStartDate).appendingFormat(" - %@", CommonModel.sharedInstance.getEventDate(dateStr: event.eventEndDate))
        }

    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
