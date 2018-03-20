//
//  Fonts.swift
//  EventApp
//
//  Created by GCO on 11/24/17.
//  Copyright © 2017 GCO. All rights reserved.
//

extension UIFont {
    
    class func getFont(fontName:String, fontStyle : String, fontSize : CGFloat) -> UIFont {
    
        let fontsArray = UIFont.fontNames(forFamilyName: fontName)
        var font : UIFont!

        var searchFont = ""
        if fontStyle == "Normal" {
            searchFont = fontName
        }
        else {
            searchFont = fontName.appendingFormat("-%@",fontStyle)
        }
      // print("fontsArray ", fontsArray)

        //Check font is supported in ios or not
        if fontsArray.contains(searchFont) {
            font = UIFont(name: searchFont, size: fontSize)!
        }
        else {
            
            //Search font
            var newFontName : String!
            let newFontStyle = fontStyle.appending("MT")
            
                
            if fontName == "Arial" {
                newFontName = fontName.appending("MT")
                
                if fontStyle != "Normal" {
                    newFontName = fontName.appendingFormat("-%@",newFontStyle )
                }
            }
            else if fontName == "Times New Roman" {
                //Remove space between name
                newFontName = fontName.replacingOccurrences(of: " ", with: "")
                newFontName = newFontName.appending("PS")
                
                if fontStyle == "Normal" {
                    newFontName = newFontName.appending("MT")
                }
                else {
                    newFontName = newFontName.appendingFormat("-%@",newFontStyle )
                }
            }
            else {
                if fontStyle == "Normal" {
                    newFontName = fontName
                }
                else {
                    newFontName = fontName.appendingFormat("-%@",fontStyle )
                }
            }
            
            //Check if font name and style is null
            if newFontName == "-" {
                font = UIFont(name: "Arial", size: 20)!
            }
            else {
                font = UIFont(name: newFontName, size: fontSize)!
            }
        }
        
        //If still not able create font then add default font
        if font == nil {
            font = UIFont(name: "Arial", size: 20)!
        }

        return font
    }

}
