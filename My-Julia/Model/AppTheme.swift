//
//  AppTheme.swift
//  My-Julia
//
//  Created by GCO on 4/10/17.
//  Copyright © 2017 GCO. All rights reserved.
//Commit on 21 April

import UIKit

//enum MenuModuleStates : NSInteger {
//    case MenuHomeModuleId = 0
//    case MenuAgendaModuleId
//    case MenuMyScheduleModuleId
//    case MenuMyNotesModuleId
//    case MenuRemindersModuleId
//    case MenuMapModuleId
//    case MenuCaptureContentModuleId
//    case MenuActivityFeedsModuleId
//    case MenuAttendeesModuleId
//    case MenuSpeakersModuleId
//    case MenuSponsorsModuleId
//    case MenuPhotoGalleryModuleId
//    case MenuNotificationsModuleId
//    case MenuEmergencyNoModuleId
//    case MenuRestaurantsModuleId
//    case MenuWiFiModuleId
//    case MenuFeedbackModuleId
//    case MenuOPollModuleId
//    case MenuSpotMeModuleId
//    case MenuChatModuleId
//};


class AppTheme: NSObject {

    //appdegate variable
   // var menuListStates : MenuModuleStates?
    
    /* Header */
    var headerColor : UIColor
    var isHeaderColor : Bool!
    var headerImage : String = "navbar_default"
    var headerTextColor : UIColor!
    var headerFontName : String!
    var headerFontStyle : String!
    var headerFontSize : Int!
    
    /* Background */
    var backgroundColor : UIColor
    var isbackgroundColor : Bool!
    var backgroundImage : String = ""
    
    /* Menu */
    var menuBackgroundColor : UIColor!
    var menuTextColor : UIColor!
    var menuFontName : String!
    var menuFontStyle : String!
    var menuFontSize : Int!
    
    /*Event Logo */
    var isEventLogoIcon : Bool = false
    var eventNameTextColor : UIColor!
    var eventIconImage : String = ""
    var eventLogoImage : String = ""
    var iconTextFontName : String!
    var iconTextFontStyle : String!
    var iconTextFontSize : Int!
    var logoText : String!

    var eventModulesData : NSArray!
    var userModuleData : NSArray!

    var navigationImageData : Data!

    // Can't init is singleton
    private override init() {
    
        headerFontName = "Arial"
        headerFontStyle = "Normal"
        headerFontSize = 18

        menuFontName = "Arial"
        menuFontStyle = "Normal"
        menuFontSize = 16
        
        iconTextFontName = "Arial"
        iconTextFontStyle = "Normal"
        iconTextFontSize = 16

        headerColor = UIColor(rgb: 0xA30046)
        isHeaderColor = true
        headerTextColor = UIColor(rgb: 0xFFFFFF)

        backgroundColor = UIColor(rgb: 0xD1D1D1)
        isbackgroundColor = true

        menuBackgroundColor = UIColor(rgb: 0xFBFBFB)
        menuTextColor = UIColor.darkGray
        
        isEventLogoIcon = false
    }
    
    func setDefaultSetting() {
        
        headerFontName = "Arial"
        headerFontStyle = "Normal"
        headerFontSize = 18
        
        menuFontName = "Arial"
        menuFontStyle = "Normal"
        menuFontSize = 14
        
        headerColor = UIColor(rgb: 0xA30046)
        isHeaderColor = true
        headerTextColor = UIColor(rgb: 0xFFFFFF)
        
        //backgroundColor = UIColor(rgb: 0xFBFBFB)
        backgroundColor = UIColor(rgb: 0xf2f2f2)
        isbackgroundColor = true
        
        menuBackgroundColor = UIColor(rgb: 0xFBFBFB)
        menuTextColor = UIColor.darkGray
        
        isEventLogoIcon = false
    }
    //MARK: Shared Instance
    
    static let sharedInstance: AppTheme = AppTheme()
    
}
