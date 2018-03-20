//
//  UIColor+.swift
//  EventApp
//
//  Created by GCO on 5/3/17.
//  Copyright © 2017 GCO. All rights reserved.
//

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    func HexToColor(hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        
        if (hexString as? NSNull) != nil {
            return UIColor.clear
        }
//        if hexString.isEmpty {
//            return UIColor.clear
//        }
        
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = NSCharacterSet.init(charactersIn: "#") as CharacterSet
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
    
    var lighterColor: UIColor {
        return lighterColor(removeSaturation: 0.5, resultAlpha: -1)
    }
    
    var darkerColor: UIColor {
        return darkerColor(removeSaturation: 0.5, resultAlpha: 1)
    }
    
    func lighterColor(removeSaturation val: CGFloat, resultAlpha alpha: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0
        var b: CGFloat = 0, a: CGFloat = 0
        
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            else {return self}
        
        return UIColor(hue: h,
                       saturation: max(s - val, 0.0),
                       brightness: b,
                       alpha: alpha == -1 ? a : alpha)
    }
    
    func darkerColor(removeSaturation val: CGFloat, resultAlpha alpha: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0
        var b: CGFloat = 0, a: CGFloat = 0
        
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            else {return self}
        
        return UIColor(hue: h,
                       saturation: max(s + val, 0.0),
                       brightness: b,
                       alpha: alpha == -1 ? a : alpha)
    }
    
    
    func getLighterColor() -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0
        var b: CGFloat = 0, a: CGFloat = 0
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: min(r + 0.2, 1.0), green: min(g + 0.2, 1.0), blue: min(b + 0.2, 1.0), alpha: 1.0)
        }
        
        return .clear
    }
    
    func getDarkerColor() -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0
        var b: CGFloat = 0, a: CGFloat = 0
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: min(r - 0.2, 1.0), green: min(g - 0.2, 1.0), blue: min(b - 0.2, 1.0), alpha: 1.0)
        }
        
        return .clear
    }
    
    //User lighter and darker color as per percentage wise
    
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
    
    //    - (UIColor *)lighterColorForColor:(UIColor *)c
    //    {
    //    if
    //    CGFloat r, g, b, a;
    //    if ([c getRed:&r green:&g blue:&b alpha:&a])
    //    return [UIColor colorWithRed:MIN(r + 0.2, 1.0)
    //    green:MIN(g + 0.2, 1.0)
    //    blue:MIN(b + 0.2, 1.0)
    //    alpha:a];
    //    return nil;
    //    }
    //
    //    - (UIColor *)darkerColorForColor:(UIColor *)c
    //    {
    //    CGFloat r, g, b, a;
    //    if ([c getRed:&r green:&g blue:&b alpha:&a])
    //    return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
    //    green:MAX(g - 0.2, 0.0)
    //    blue:MAX(b - 0.2, 0.0)
    //    alpha:a];
    //    return nil;
    //    }
    
    func setIconColorImageToButton(button: UIButton, image: String) {
        
        let image = UIImage(named: image)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = AppTheme.sharedInstance.backgroundColor.darker(by: 45)!
        
    }

    func setButtonColorImageToButton(button: UIButton, image: String) {
        
        let image = UIImage(named: image)?.withRenderingMode(.alwaysTemplate)
        button.setBackgroundImage(image, for: .normal)
        button.tintColor = AppTheme.sharedInstance.backgroundColor.darker(by: 45)!

    }
    
}
