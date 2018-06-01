//
//  CustomUITextField.swift
//  My-Julia
//
//  Created by GCO on 22/03/2018.
//  Copyright © 2018 GCO. All rights reserved.
//

import UIKit

class CustomUITextView: UITextView{

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) || action == #selector(paste(_:))  || action == #selector(select(_:))  || action == #selector(selectAll(_:))  || action == #selector(cut(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
