//
//  MyNotesListViewController.swift
//  My-Julia
//
//  Created by GCO on 5/16/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

protocol MyNoteDelegate: class {
    
    func saveNewNoteDelegate(_ note: Notes, _isEditNote: Bool)
}


class MyNotesListViewController: UIViewController, MyNoteDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    
    //var listArray: [Notes] = NSMutableArray() as! [Notes]
    var listArray = [Notes]()
    
    var selectedIndex: NSInteger = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()

        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Fetch data from Sqlite database
        DispatchQueue.main.async {
            // Update UI
            self.listArray = DBManager.sharedInstance.fetchAllNotesListFromDB() as! [Notes]
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destinationVC = segue.destination as! AddNoteViewController
        destinationVC.delegate = self
        
        if segue.identifier == "EditNoteSegueIdentifier" {
            if let indexPath = tableView.indexPathForSelectedRow {
                selectedIndex = indexPath.row
                destinationVC.isNewNote = false
                destinationVC.noteModel = listArray[indexPath.row]
            }
        }
    }
    
    // MARK: - Navigation UIBarButtonItems
    
    func setupMenuBarButtonItems() {
        // self.navigationItem.rightBarButtonItem = self.rightMenuBarButtonItem()
        let barItem = CommonModel.sharedInstance.leftMenuBarButtonItem()
        barItem.target = self;
        barItem.action = #selector(self.leftSideMenuButtonPressed(sender:))
        self.navigationItem.leftBarButtonItem = barItem
    }
    
    @objc func leftSideMenuButtonPressed(sender: UIBarButtonItem) {
        let masterVC : UIViewController!
        if IS_IPHONE {
            masterVC =  self.menuContainerViewController.leftMenuViewController as! MenuViewController!
        }
        else {
            masterVC = self.splitViewController?.viewControllers.first
        }
        
        if ((masterVC as? MenuViewController) != nil) {
            (masterVC as! MenuViewController).toggleLeftSplitMenuController()
        }
    }
    
   
    @IBAction func displayShareSheet(sender: Any) {
        
        var html = ""
        
        for index in 0 ... listArray.count {
            if index < listArray.count {
                let model = listArray[index] as Notes

                print("model.titleStr : ",model.titleStr)
                model.titleStr = model.titleStr.replacingOccurrences(of: "\n", with: "<br>")
                model.messageStr = model.messageStr.replacingOccurrences(of: "\n", with: "<br>")

                // If title and message is equal then remove dublication
                if model.titleStr == model.messageStr {
                    html = html.appendingFormat("<div style='text-align:justify; font-size:14px;font-family:HelveticaNeue;color:#362932;'><b> %@. %@</b><p></p><br>",String(format:"%d",index+1),model.titleStr)
                }
                else {
                    html = html.appendingFormat("<div style='text-align:justify; font-size:14px;font-family:HelveticaNeue;color:#362932;'><b> %@. %@</b> <p> %@</p><br>",String(format:"%d",index+1),model.titleStr,model.messageStr)
                }
            }
        }

        CommonModel.sharedInstance.createPDF(content: html, pdfName: "MyNotes")
        
        //Share PDF File
        let filename = String(format: "MyNotes_%@_%@", EventData.sharedInstance.eventId,AttendeeInfo.sharedInstance.attendeeId)

        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentoPath = "\(documentsPath)/\(filename).pdf"

        
        let activityViewController: UIActivityViewController!
        
        var document : NSData!
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: documentoPath){
            document = NSData(contentsOfFile: documentoPath)
            activityViewController = UIActivityViewController(activityItems: [document], applicationActivities: nil)
        }
        else {
            activityViewController = UIActivityViewController(activityItems: [""], applicationActivities: nil)
        }
        
        if (activityViewController.popoverPresentationController != nil) {
            activityViewController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        }
        self.present(activityViewController, animated: true, completion: nil)

    }
    
    // MARK: - UITableView DataSource Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if listArray.count == 0 {
            return 1
        }
        else {
            return listArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if listArray.count == 0 {
            return 110
        }
        else {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if listArray.count == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyNoteIdentifier", for: indexPath)
            tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            cell.backgroundColor = cell.contentView.backgroundColor;

            let button = cell.viewWithTag(1000) as! DesignableButton
            button.showButtonTheme()

            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCustomCell", for: indexPath) as! NoteCustomCell
            tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            cell.backgroundColor = cell.contentView.backgroundColor;

            var model : Notes
            model = listArray[indexPath.row]
            
            cell.titleLabel?.text = model.titleStr
            cell.dateLabel.text = CommonModel.sharedInstance.getDateAndTime(dateStr:model.dateStr)
            
            return cell
        }
    }
    
    // Override to support conditional editing of the table view.
    // This only needs to be implemented if you are going to be returning NO
    // for some items. By default, all items are editable.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return YES if you want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            DBManager.sharedInstance.deleteNoteDataIntoDB(note: listArray[indexPath.row])
            listArray.remove(at: indexPath.row)

            //Delete section if deleted row is last row of section
            if listArray.count == 0 {
               //let indexSet = NSMutableIndexSet()
//                indexSet.add(indexPath.section)
//                tableView.deleteSections(indexSet as IndexSet, with: UITableViewRowAnimation.automatic)
                self.tableView.reloadData()
            }
            else {
                //Delete selected row
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.bottom)
            }
        }
    }
    
    // MARK: - MyNoteDelegate Methods
    
    func saveNewNoteDelegate(_ note: Notes, _isEditNote: Bool) {
        
        //Save into array and reload it into list
        if _isEditNote  {
            listArray.remove(at: selectedIndex)
            listArray.insert(note, at: selectedIndex)
            DBManager.sharedInstance.updateNoteDataIntoDB(note: note)
        }
        else {
            listArray.insert(note, at: 0)
            DBManager.sharedInstance.saveNewNoteDataIntoDB(note: note)
        }
        tableView.reloadData()
    }
}

// MARK: - Custom Cell Classes

class NoteCustomCell: UITableViewCell {
    
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var dateLabel:UILabel!
    
}
