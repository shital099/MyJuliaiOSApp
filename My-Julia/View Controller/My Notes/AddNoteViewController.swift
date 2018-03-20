//
//  AddNoteViewController.swift
//  EventApp
//
//  Created by GCO on 5/16/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class AddNoteViewController: UIViewController {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var textView: DALinedTextView!

    var noteModel = Notes()
    var isNewNote : Bool = true
    var isFromMySchedule : Bool = false
    var delegate : MyNoteDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        textView.becomeFirstResponder()
        textView.text = noteModel.messageStr

        textView.textColor = AppTheme.sharedInstance.backgroundColor.darker(by:40)
        textView.backgroundColor = UIColor.clear
       // textView.horizontalLineColor = AppTheme.sharedInstance.backgroundColor.darker(by:10)
       // textView.verticalLineColor = UIColor.clear

        if isFromMySchedule {
            self.title = noteModel.titleStr
        }
        else {
            if !isNewNote {
                self.title = "Edit note"
            }
            else {
                self.title = "New note"
            }
        }
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

    // MARK: - Button Action Methods
    
    @IBAction func onClickOfSaveBtn(sender: Any)  {
        noteModel.messageStr = textView.text
        
        if self.isFromMySchedule {
            
            if noteModel.id == nil {
                DBManager.sharedInstance.saveNewNoteDataIntoDB(note: noteModel)
                CommonModel.sharedInstance.showAlertNotification(view: self.view, title: Agenda_Sucess, message: Note_Sucess, alertType: TKAlertType.TKAlertTypeError.rawValue)
            }
            else {
                DBManager.sharedInstance.updateNoteDataIntoDB(note: noteModel)
                CommonModel.sharedInstance.showAlertNotification(view: self.view, title: Agenda_Sucess, message: Note_Update, alertType: TKAlertType.TKAlertTypeError.rawValue)
            }
        }
        else {
            if noteModel.sessionId == "" {
                if textView.text.isEmpty {
                    noteModel.titleStr = "New Note"
                } else {
                    noteModel.titleStr = textView.text
                    noteModel.messageStr = textView.text
                }
            }

            //call delegate method to Pass note message to last screen and save it.
            delegate.saveNewNoteDelegate(noteModel, _isEditNote: !isNewNote)
        }
        
        self.navigationController?.popViewController(animated: true)
    }

}
