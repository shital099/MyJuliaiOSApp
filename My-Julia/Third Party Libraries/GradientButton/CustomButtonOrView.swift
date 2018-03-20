//
//  CustomButtonOrView.swift
//  Chime
//
//  Created by Michael McChesney on 3/4/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

@IBDesignable class DesignableButton: UIButton {

    // IBInspectable properties for the gradient colors
    @IBInspectable var bottomColor: UIColor = UIColor(red:0.98, green:0.49, blue:0.2, alpha:1)
    @IBInspectable var middleColor: UIColor = UIColor(red:0.98, green:0.85, blue:0.38, alpha:1)
    @IBInspectable var topColor: UIColor = UIColor(red:0.98, green:0.49, blue:0.2, alpha:1)
    @IBInspectable var bottomColorAlpha: CGFloat = 1.0
    @IBInspectable var middleColorAlpha: CGFloat = 1.0
    @IBInspectable var topColorAlpha: CGFloat = 1.0

    // IBInspectable properties for rounded corners and border color / width
    @IBInspectable var cornerSize: CGFloat = 15
    @IBInspectable var borderSize: CGFloat = 1
    @IBInspectable var borderColor: UIColor = UIColor.black
    @IBInspectable var borderAlpha: CGFloat = 1.0
    
    override func draw(_ rect: CGRect) {

        // set up border and cornerRadius
        self.layer.cornerRadius = cornerSize
        self.layer.borderColor = borderColor.withAlphaComponent(borderAlpha).cgColor
        self.layer.borderWidth = borderSize
        self.layer.masksToBounds = true
        
        // set up gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = rect
        let c1 = bottomColor.withAlphaComponent(bottomColorAlpha).cgColor
        let c2 = middleColor.withAlphaComponent(middleColorAlpha).cgColor
        let c3 = topColor.withAlphaComponent(topColorAlpha).cgColor
        gradientLayer.colors = [c3, c2, c1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }

    func showButtonTheme() {
        
        self.topColor = AppTheme.sharedInstance.backgroundColor.getDarkerColor()
        self.middleColor = AppTheme.sharedInstance.backgroundColor.darker(by: 5)!
        self.bottomColor = AppTheme.sharedInstance.backgroundColor.getDarkerColor()
        
        self.borderColor = AppTheme.sharedInstance.backgroundColor.darker(by: 30)!
        self.setTitleColor(AppTheme.sharedInstance.backgroundColor.darker(by: 45)!, for: .normal)
    }
}

@IBDesignable class DesignableView: UIView {
    
    // IBInspectable properties for the gradient colors
    @IBInspectable var bottomColor: UIColor = UIColor(red:0.16, green:0.17, blue:0.21, alpha:1)
    @IBInspectable var middleColor: UIColor = UIColor(red:0.98, green:0.85, blue:0.38, alpha:1)
    @IBInspectable var topColor: UIColor = UIColor(red:0.16, green:0.17, blue:0.21, alpha:1)
    @IBInspectable var bottomColorAlpha: CGFloat = 1.0
    @IBInspectable var middleColorAlpha: CGFloat = 0.8
    @IBInspectable var topColorAlpha: CGFloat = 1.0
    
    // IBInspectable properties for rounded corners and border color / width
    @IBInspectable var cornerSize: CGFloat = 0
    @IBInspectable var borderSize: CGFloat = 0
    @IBInspectable var borderColor: UIColor = UIColor.black
    @IBInspectable var borderAlpha: CGFloat = 1.0
    
    override func draw(_ rect: CGRect) {
        
        // set up border and cornerRadius
        self.layer.cornerRadius = cornerSize
        self.layer.borderColor = borderColor.withAlphaComponent(borderAlpha).cgColor
        self.layer.borderWidth = borderSize
        self.layer.masksToBounds = true
        
        // set up gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = rect
        let c1 = bottomColor.withAlphaComponent(bottomColorAlpha).cgColor
        let c2 = middleColor.withAlphaComponent(middleColorAlpha).cgColor
        let c3 = topColor.withAlphaComponent(topColorAlpha).cgColor
        gradientLayer.colors = [c3, c2, c1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        self.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
}
