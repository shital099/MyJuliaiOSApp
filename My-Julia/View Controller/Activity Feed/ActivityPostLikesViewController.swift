//
//  ActivityPostLikesViewController.swift
//  EventApp
//
//  Created by GCO on 07/02/2018.
//  Copyright © 2018 GCO. All rights reserved.
//

import UIKit

class ActivityPostLikesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    var listArray:NSMutableArray = []
    var activityPostId : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.title = "Likes"

        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)

        tableView.tableFooterView = UIView()

        //Update dyanamic height of tableview cell
        tableView?.estimatedRowHeight = 150
        tableView?.rowHeight = UITableViewAutomaticDimension

        //Fetch data from Sqlite database
        self.listArray = DBManager.sharedInstance.fetchActivityFeedsLikesDataFromDB(activityFeedId: self.activityPostId).mutableCopy() as! NSMutableArray

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

    // MARK: - Webservice Methods

 /*   func getComments() {

        NetworkingHelper.getRequestFromUrl(name:Get_PostLikes_url,  urlString: Get_PostLikes_url.appendingFormat(activityPostId), callback: { response in

            //Parse likes data
            for item in response as! NSArray{
                let  dict = item as! NSDictionary

                let model = ActivityLikeModel()
                model.userId = dict.value(forKey: "Id") as! String!
                model.name = DBManager.sharedInstance.isNullString(str: dict.value(forKey: "Name") as Any)
                model.userIconUrl =  DBManager.sharedInstance.isNullString(str: dict.value(forKey: "Name") as Any)

                self.listArray.add(model)
            }
            self.tableView.reloadData()

        }, errorBack: { error in
        })
    }*/

    // MARK: - UITableView DataSource Methods

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! LikesCustomCell
        cell.backgroundColor = cell.contentView.backgroundColor;

        let model = self.listArray[indexPath.row] as! ActivityLikeModel
        cell.nameLabel.text = model.name

        if !model.userIconUrl.isEmpty {
            let url = NSURL(string:model.userIconUrl)! as URL
            cell.userImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "user"))
            cell.userImageView?.layer.cornerRadius = cell.userImageView.frame.size.height/2
            cell.userImageView.clipsToBounds = true
        }
        else {
            cell.userImageView.image = #imageLiteral(resourceName: "user")
        }

        return cell
    }
}

// MARK: - Custom Cell Classes

class LikesCustomCell: UITableViewCell {

    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var userImageView:UIImageView!

}
