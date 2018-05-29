//
//  PollHistoryViewController.swift
//  My-Julia
//
//  Created by GCO on 9/26/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import Foundation

class PollHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLbl: UILabel!

    var sessionModel = SessionsModel()
    var listArray:[PollModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Poll history"
        
        //Update dyanamic height of tableview cell
        tableView.estimatedRowHeight = 800
        tableView.rowHeight = UITableViewAutomaticDimension

        self.listArray = DBManager.sharedInstance.fetchPollActivityQuestionsListFromDB(sessionId: self.sessionModel.sessionId, activityId: self.sessionModel.activityId) as! [PollModel]

        //Fetch activity questions
        self.fetchActivityQuestionList()
    }
    
    // MARK: - Webservice Methods
    func fetchActivityQuestionList() {
        
        let urlStr = GetPoll_Question_List_url.appendingFormat("%@",self.sessionModel.activityId)
        
        NetworkingHelper.getRequestFromUrl(name:GetPoll_Question_List_url,  urlString:urlStr, callback: { [weak self] response in
            self?.listArray = DBManager.sharedInstance.fetchPollActivityQuestionsListFromDB(sessionId: (self?.sessionModel.sessionId)!, activityId: (self?.sessionModel.activityId)!) as! [PollModel]
            self?.tableView.reloadData()
            
            if self?.listArray.count == 0 {
                self?.messageLbl.isHidden = false
                self?.messageLbl.text = No_Poll_History_Text
            }else {
                self?.messageLbl.isHidden = true
            }
        }, errorBack: { error in
            NSLog("error : %@", error)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView Data Source Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChartBarCell", for: indexPath) as! ChartBarCell
        cell.backgroundColor = cell.contentView.backgroundColor;
        
//        cell.progressView.addOption("Column", action: cell.columnSelected);
//        cell.progressView.addOption("Bar", action: cell.barSelected);
        let model = listArray[indexPath.row] 
        cell.questionLbl.text = model.questionText
        
        for i in 0..<model.optionsArr.count {
            let optionDict = model.optionsArr[i] as! NSDictionary
            
            switch i {
            case 0:
                cell.optionLbl1.text = optionDict["OptionValue"] as? String
                break
            case 1:
                cell.optionLbl2.text = optionDict["OptionValue"] as? String
                break
            case 2:
                cell.optionLbl3.text = optionDict["OptionValue"] as? String
                break
            case 3:
                cell.optionLbl4.text = optionDict["OptionValue"] as? String
                break
            default:
                break
            }
        }
        
        var frame = cell.progressView.bounds
        frame.origin.x = 0
        frame.origin.y = 0
        cell.chart.frame = frame
        
        cell.chart.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
        cell.progressView.addSubview(cell.chart)
        
       // cell.rangeColumnSelected(arr : model.optionsArr)

        cell.columnSelected(arr : model.optionsArr, isSelected: true)
        return cell
    }
}

// MARK: - Custom Cell Classes

class ChartBarCell: UITableViewCell {
    
    @IBOutlet weak var progressView:UIView!
    @IBOutlet weak var questionLbl: UILabel!
    @IBOutlet weak var optionLbl1: UILabel!
    @IBOutlet weak var optionLbl2: UILabel!
    @IBOutlet weak var optionLbl3: UILabel!
    @IBOutlet weak var optionLbl4: UILabel!
    @IBOutlet weak var optionImage1: UIImageView!
    @IBOutlet weak var optionImage2: UIImageView!
    @IBOutlet weak var optionImage3: UIImageView!
    @IBOutlet weak var optionImage4: UIImageView!
    let xValues = ["A", "B", "C", "D", "E"]

    let chart = TKChart()

    func columnSelected(arr : Array<Any>, isSelected : Bool) {
        chart.removeAllData()
        
        /** Add options bar **/
        // >> chart-column-swift
        var items = [TKChartDataPoint]()
        for i in 0..<arr.count {
            let dict = arr[i] as! NSDictionary
            let data = TKChartDataPoint(x:xValues[i], y:dict["Count"])
            items.append(data)
            //      let data = TKChartDataPoint(x:(i+1), y:Int(arc4random()%100))
        }
        
        let series = TKChartColumnSeries(items:items)
        series.style.paletteMode = TKChartSeriesStylePaletteMode.useItemIndex
        series.selection = TKChartSeriesSelection.none
        
        // >> chart-width-cl-swift
        series.maxColumnWidth = 50
        series.minColumnWidth = 30
        chart.addSeries(series)
        
        /** Add extra bar **/
        //Add one last column bar with clear color for keeping constant y axis value
        var items1 = [TKChartDataPoint]() //last hidden colum bar
        items1.append(TKChartDataPoint(x:" ", y:20))
        let series1 = TKChartColumnSeries(items:items1)
        series1.style.paletteMode = TKChartSeriesStylePaletteMode.useItemIndex
        series1.selection = TKChartSeriesSelection.none
        series1.maxColumnWidth = 2
        series1.minColumnWidth = 0
        series1.style.palette = TKChartPalette()
        
        let paletteItem = TKChartPaletteItem()
        paletteItem.fill = TKSolidFill(color: UIColor.clear)
        paletteItem.stroke = TKStroke(color: UIColor.clear)
        series1.style.palette!.addItem(paletteItem)
        chart.addSeries(series1)
        
        //        //Show user anser selected
        //        if isSelected {
        //            series.style.palette = TKChartPalette()
        //
        //            let paletteItem = TKChartPaletteItem()
        //            paletteItem.fill = TKSolidFill(color: UIColor.red)
        //            paletteItem.stroke = TKStroke(color: UIColor.black)
        //            series.style.palette!.addItem(paletteItem)
        //            chart.addSeries(series)
        //        }
        
        // << chart-column-swift
        
        chart.reloadData()
    }
    
    func barSelected() {

        chart.removeAllData()
        // >> chart-bar-swift
        var items = [TKChartDataPoint]()
        for i in 0..<4 {
            items.append(TKChartDataPoint(x:Int(arc4random()%100), y:(i+1)))
        }
        
        let series = TKChartBarSeries(items:items)
        series.style.paletteMode = TKChartSeriesStylePaletteMode.useItemIndex
        series.selection = TKChartSeriesSelection.dataPoint
        chart.addSeries(series)
        // << chart-bar-swift
        chart.reloadData()
    }

}

