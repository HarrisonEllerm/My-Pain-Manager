//
//  SummaryController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Sebastian Peden on 4/21/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import Foundation


import UIKit
import Firebase
import Foundation
import FirebaseDatabase
import FirebaseAuth
import DateToolsSwift
import SwiftDate
import NotificationBannerSwift
import SwiftyBeaver
import SwiftSpinner

class SummaryController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var didLayout: Bool = false
    private var lineModelData = [LineDataWrapper]()
    private var typeKeyMap = Dictionary<String, UIColor>()
    private var isLoadingViewController = false
    private let numberOfDateOptions = 2
    private var xAxisScale : Double?
    private var scaleMultiplier : Double?
    private var startDate : Date?
    private var endDate : Date?
    private var maxDifference: Int?
    private let _units : Double = 24.0
    private let log = SwiftyBeaver.self
    private var wrappers: [LogWrapper] = []
    
    private let summaryTableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.isScrollEnabled = true
        t.tableFooterView = UIView(frame: .zero)
        t.allowsSelection = true
        t.allowsMultipleSelection = false
        t.separatorInset = .zero
        t.layoutMargins = .zero
        return t
    }()
    
    private var chartContainer : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var keyContainer : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /**
     This will be run once, therefore here we do everything that
     doesn't need to be repeated when the view controller is refreshed.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        isLoadingViewController = true
        Service.setupNavBar(controller: self)
        self.navigationItem.title = "Summary"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Report", style: .done, target: self, action: #selector(handleReportButtonOnTap))
        self.navigationController?.navigationBar.tintColor = UIColor(r: 254, g: 162, b: 25)
        setupView()
        //Controller listens for changes in state of date cells
        NotificationCenter.default.addObserver(self, selector: #selector(self.dateSet), name: NSNotification.Name(rawValue: "dateSet"), object: nil)
        endDate = Date().dateAtStartOf(.day)
        startDate = endDate?.subtract(TimeChunk.init(seconds: 0, minutes: 0, hours: 0, days: 1, weeks: 0, months: 0, years: 0))
        if let start = startDate, let end = endDate {
            getDataForTimePeriod(date1: start, date2: end)
        }
    }
    
    /**
        Employed to allow the dynamic refreshing of data
        when a user opens the tab again, after it has
        initially been loaded via viewDidLoad().
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isLoadingViewController {
            isLoadingViewController = false
        } else {
            setupView()
        }
    }
    
    /**
        Sets up the parts of the view that need to be
        dynamically reloaded if a user opens the tab
        after it has initially loaded.
    */
    private func setupView() {
        view.addSubview(summaryTableView)
        setupSummaryTableView()
        view.addSubview(chartContainer)
        setupChartContainer()
        chartContainer.addSubview(keyContainer)
        setupKeyContainer()
        setupSummaryTableViewSpecifics()
        if let start = startDate, let end = endDate {
            getDataForTimePeriod(date1: start, date2: end)
        }
    }
    
    /**
        Sets up summary table view properties.
    */
    private func setupSummaryTableViewSpecifics() {
        summaryTableView.delegate = self
        summaryTableView.dataSource = self
        summaryTableView.rowHeight = 44
        summaryTableView.isScrollEnabled = false
        summaryTableView.allowsSelection = true
        summaryTableView.register(GraphDateEntryCell.self, forCellReuseIdentifier: "graphDateEntry")
    }
    
    //Handles generation of the report
    @objc func handleReportButtonOnTap() {
        SwiftSpinner.show("Building Report")
        for item in wrappers {
            print(item.getType())
            print(item.getTime())
            print(item.getRating())
        }
        SwiftSpinner.hide()
    }
    
    
    /**
        Triggered when a date is set insid a GraphDateEntryCell. UserInfo is passed
        into the function that identifies if the date is the From or To date in terms
        of the period, and it is handled accordingly.
     
        - parameter : notif, the notification
    */
    @objc func dateSet(notif: NSNotification) {
        if let name = notif.userInfo?["name"] as? String, let date = notif.userInfo?["date"] as? String {
            if name == "From" {
                startDate = date.toDate("dd/MM/yyyy")?.date
            } else {
                endDate = date.toDate("dd/MM/yyyy")?.date
            }
        }
        if let start = startDate, let end = endDate {
            if start.equals(end) || start.isEarlier(than: end) {
                getDataForTimePeriod(date1: start, date2: end)
            }
        }
    }
    
    /**
        Queries Firebase for the logs of data associated with a users
        account, wraps those logs up into an object for simplicity, and
        passes them to a function which cleans the data and builds the
        graph.
     
        - parameter : date1, the first date.
        - parameter : date2, the second date.
    */
    private func getDataForTimePeriod(date1: Date, date2: Date) {
        //Clear line model data
        lineModelData.removeAll()
        
        //Setup differences needed for scaling
        setupDifferences(date1, date2)
       
        //reformat dates so we can pull data
        let dateF : DateFormatter = DateFormatter()
        dateF.dateFormat = "yyyy-MMM-dd"
        dateF.timeZone = TimeZone(abbreviation: "Pacific/Auckland")
        let dateFromS = dateF.string(from: date1)
        let dateToS = dateF.string(from: date2)
        
        let noDataBanner = NotificationBanner(title: "No Data for Specified Period!", subtitle: "Try entering some data to view a summary...", style: .warning)
        
        if Auth.auth().currentUser != nil {
            if let uid = Auth.auth().currentUser?.uid {
                
                let painRef = Database.database().reference(withPath: "pain").child(uid)
                //Refresh data and ignore cache
                painRef.keepSynced(true)
              
                painRef.queryOrderedByKey().queryStarting(atValue: dateFromS).queryEnding(atValue: dateToS).observeSingleEvent(of: .value) { (snapshot) in
                    self.log.info("User \(uid) searching for data in range: \(dateFromS) to \(dateToS)")
                    
                   if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {

                    if snapshots.isEmpty {
                        self.log.info("User \(uid) had incomplete/missing data in range, checking for partial data")
                        self.checkForIncompleteDataInPeriod(uid, dateFromS, date1, date2, noDataBanner)
                    } else {
                        for snap in snapshots {
                                let date = snap.key
                                if let subchildren = snap.children.allObjects as? [DataSnapshot] {
                                    for snap in subchildren {
                                        if let values = snap.value as? Dictionary<String, Any> {
                                            let time = date + " " + snap.key
                                            guard let rating : Int = values["ranking"] as? Int else { return }
                                            guard let type : String = values["type"] as? String else { return }
                                            let w = LogWrapper(time, rating, type)
                                            self.wrappers.append(w)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    //Have all the data needed to build out graph
                    self.buildChart(self.wrappers)
                }
            }
        }
    }
    
    /**
        A function that is called if the snapshot is empty between the
        ranges the user initially input. The reason this exists is to basically
        check to see if there is ANY data in the time period asked for, i.e.
        incomplete data. If there is, this function attempts to find it and then
        continues on to display that data. To avoid searching for their last logged
        entry, we store a "last_logged" timestamp in a "users_metadata" node within
        the database, so we can quickly figure out if the user has viable data within
        the range they requested.
     
        - parameter : uid, the users unique identifier.
        - parameter : dateFromS, the original "from" date in String format.
        - parameter : date1, the intiial "from" date.
        - parameter : date2, the initial "to" date.
        - parameter : noDataBanner, a banner used to display a message to the user
    */
    private func checkForIncompleteDataInPeriod(_ uid: String,_ dateFromS: String, _ date1: Date, _ date2: Date, _ noDataBanner: NotificationBanner) {
        Database.database().reference(withPath: "users_metadata").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                if snapshots.isEmpty {
                self.log.info("User \(uid) had no data in the date range.")
                noDataBanner.show()
                } else {
                    for snap in snapshots {
                        if let lastActive : String = snap.value as? String {
                            guard let last = lastActive.toDate()?.date else { return }
                            if last.isAfterDate(date1, granularity: .day) {
                                self.getDataForTimePeriod(date1: date1, date2: last)
                                let banner = NotificationBanner(title: "Some data was missing!", subtitle: "Displaying data from \(dateFromS) till \(lastActive)", style: .success)
                                self.log.info("User \(uid) had partial data in the date range.")
                                banner.show()
                            } else {
                                noDataBanner.show()
                                self.log.info("User \(uid) had no data in the date range.")
                            }
                        }
                    }
                }
            }
        })
    }
    
    /**
        A utility method used to find the difference in days, so that we
        can scale the data appropriately.
     
        - parameter : date1, the first date.
        - parameter : date2, the second date.
    */
    private func setupDifferences(_ date1: Date, _ date2: Date) {
        let days = getDaysBetweenDates(firstDate: date1, secondDate: date2)+1
        xAxisScale = Double(days)*_units
        maxDifference = days
    }
    
    
    /**
        Builds the chart out, by collecting data relevant to certain
        types of pain and setting up the line data for those types of pain.
        Finally, after this is complete, the chart is initiated.
     
        - parameter : date1, the first date.
        - parameter : date2, the second date.
     */
    private func buildChart(_ wrappers: [LogWrapper]) {
        //Pull data that is from the same area and place them into
        //mapped wrappers, so that we can eventually graph them.
        var mappedWrappers : Dictionary<String, [LogWrapper]> = Dictionary()
        for item in wrappers {
            if mappedWrappers[item.getType()] != nil {
                mappedWrappers[item.getType()]?.append(item)
                
            } else {
                mappedWrappers.updateValue([item], forKey: item.getType())
            }
        }
        //Get data into correct format for graphing
        for area in mappedWrappers {
            setupAndScaleLineData(area: area.key, wrapper: area.value)
        }
        
    }
    
    /**
        A function that sets up the linedata for a particular area.
     
        - parameter : area, a String representing the area.
        - parameter : wrapper, a log wrapper array containing the logs for that area.
     */
    private func setupAndScaleLineData(area: String, wrapper: [LogWrapper]){
        let lineData = LineDataWrapper()
        var dataHolder = [(Double,Double)]()
        //So that it has somewhere to draw from
        dataHolder.append((0.0,0.0))
        for item in wrapper {
            lineData.setType(item.getType())
            guard let dateFrom = startDate, let dateTo = item.getTime().toDate() else { return }
            let difference = getDaysBetweenDates(firstDate: dateFrom, secondDate: dateTo.date)
            let doubleTime: Double = getDoubleFromTimeString(input: item.getTime(), difference: Double(difference))
            let doubleRating = Double(item.getRating())
            dataHolder.append((doubleTime,doubleRating))
        }
        
        lineData.setLineModelData(dataHolder)
        lineModelData.append(lineData)
    }
    
    /**
        A function that takes two dates and does a comparison using
        a granularity level of days.
     
        - parameter : firstDate, the first date.
        - parameter : secondDate, the second date.
        - returns: an Int representing the difference in days.
     */
    func getDaysBetweenDates(firstDate: Date, secondDate: Date) -> Int {
        let diff = secondDate.timeIntervalSince(firstDate)
        let hours = Int(diff) / 3600
        return hours/Int(_units)
    }

    /**
        Implemented as it allows us to investigate the keyContainers
        subviews (a variable amount of UITextViews) representing chart
        keys for types of pain logged. Once identified we remove them
        so that they can be dynamically redrawn when the user opens the
        tab again.
     
        - parameter : animated, a default boolean.
     */
//    override func viewDidDisappear(_ animated: Bool) {
//        for item in keyContainer.subviews {
//            item.removeFromSuperview()
//        }
//    }
    
    /**
        Sets up the chart keys via investigating the map which holds the
        color associated with a pain type (which is randomly generated)
        and the pain types name.
     */
//    private func setupChartKey() {
//        var yCounter : CGFloat = 0.0
//        for item in typeKeyMap {
//            let someFrame = CGRect(x: 30.0, y: yCounter, width: 750, height: 30.0)
//            let newTextField = UITextField(frame: someFrame)
//            newTextField.text = item.key
//            newTextField.textColor = item.value
//            newTextField.allowsEditingTextAttributes = false
//            keyContainer.addSubview(newTextField)
//            yCounter = yCounter + 20
//        }
//    }
    
    /**
        A utility method used to format the input date into a double value
        that represents the time in 24 hour format. Takes into consideration
        the day that the time fell within the time period being graphed,
        in order to determine the corresponding x value.
     
        - parameter : input, an input String
        - returns: Double, the double value of the String
    */
    func getDoubleFromTimeString(input: String, difference: Double) -> Double {
        let timeSplit = input.split(separator: " ")
        let timeTidied = timeSplit[1].dropLast(3).replacingOccurrences(of: ":", with: ".")
        let timeDouble = Double(timeTidied)
        guard let unwrappedTime = timeDouble else { return 0.0 }
        let adjustment = ((_units*difference) + unwrappedTime)
        return adjustment
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateF : DateFormatter = DateFormatter()
        dateF.dateFormat = "dd/MM/yyyy"
        dateF.timeZone = TimeZone(abbreviation: "Pacific/Auckland")
        
        if (indexPath.row == 0) {
            let cell = self.summaryTableView.dequeueReusableCell(withIdentifier: "graphDateEntry") as! GraphDateEntryCell
            cell.textFieldName = "From"
            if let start = startDate {
                let startString = dateF.string(from: start)
                cell.textFieldValue = startString
            }
            cell.accessoryType = .disclosureIndicator
            cell.layoutSubviews()
            return cell
        } else {
            let cell = self.summaryTableView.dequeueReusableCell(withIdentifier: "graphDateEntry") as! GraphDateEntryCell
            cell.textFieldName = "To"
            if let end = endDate {
                let endString = dateF.string(from: end)
                cell.textFieldValue = endString
            }
            cell.accessoryType = .disclosureIndicator
            cell.layoutSubviews()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.black
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfDateOptions
    }

    private func setupChartContainer() {
        chartContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -120).isActive = true
        chartContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: -20).isActive = true
        chartContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 20).isActive = true
        chartContainer.bottomAnchor.constraint(equalTo: summaryTableView.safeAreaLayoutGuide.topAnchor).isActive = true
    }
    
    private func setupKeyContainer() {
        keyContainer.topAnchor.constraint(equalTo: chartContainer.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        keyContainer.leftAnchor.constraint(equalTo: chartContainer.safeAreaLayoutGuide.leftAnchor).isActive = true
        keyContainer.rightAnchor.constraint(equalTo: chartContainer.safeAreaLayoutGuide.rightAnchor).isActive = true
        keyContainer.bottomAnchor.constraint(equalTo: chartContainer.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func setupSummaryTableView() {
        summaryTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        summaryTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        summaryTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        summaryTableView.heightAnchor.constraint(equalToConstant: 88).isActive = true
    }
    
}

/**
 A wrapper object used to pull information from Firebase which
 exists in nodes that look like:
 
 2018-Jul-25
 - 20:46:47
    - ranking: 3
    - type: "Lower back"
 - 20:47:03
   - ranking: 4
   - type: "Collarbone"
 ...
2018-Jul-26
 ...
 
 */
private class LogWrapper {
    
    let time: String
    let rating: Int
    let type: String
    
    init(_ time: String, _ rating: Int, _ type: String) {
        self.time = time
        self.rating = rating
        self.type = type
    }
    
    func getTime() -> String {
        return self.time
    }
    
    func getRating() -> Int {
        return self.rating
    }
    
    func getType() -> String {
        return self.type
    }
}

/**
 A wrapper object that holds the x and y
 co-ordinates for a item being plotted, as well
 as the type of pain associated with that value.
 */
private class LineDataWrapper {
    
    var lineModelData = [(Double, Double)]()
    var type: String = ""
    
    func setType(_ type: String) {
        self.type = type
    }
    
    func getType() -> String {
        return self.type
    }
    
    func getLineModelData() -> [(Double, Double)] {
        return self.lineModelData
    }
    
    func setLineModelData(_ model: [(Double, Double)]) {
        self.lineModelData = model
    }
}


