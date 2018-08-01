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
import SwiftCharts
import FirebaseDatabase
import FirebaseAuth
import DateToolsSwift
import SwiftDate
import NotificationBannerSwift

class SummaryController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var chart: Chart?
    private var didLayout: Bool = false
    private var lineModelData = [LineDataWrapper]()
    private var typeKeyMap = Dictionary<String, UIColor>()
    private var isLoadingViewController = false
    private let numberOfDateOptions = 2
    //xAxis scale Will be dynamic eventually
    private var xAxisScale : Double?
    private var startDate : Date?
    private var endDate : Date?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isLoadingViewController = true
        setupView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.dateSet), name: NSNotification.Name(rawValue: "dateSet"), object: nil)
        endDate = Date().dateAtStartOf(.day)
        startDate = endDate?.subtract(TimeChunk.init(seconds: 0, minutes: 0, hours: 0, days: 1, weeks: 0, months: 0, years: 0))
        if let start = startDate, let end = endDate {
            getDataForTimePeriod(date1: start, date2: end)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
                print(date)
                startDate = date.toDate("dd/MM/yyyy")?.date
            } else {
                print(date)
                endDate = date.toDate("dd/MM/yyyy")?.date
            }
        }
        if (startDate != nil && endDate != nil) {
            if startDate!.isEarlier(than: endDate!) {
                getDataForTimePeriod(date1: startDate!, date2: endDate!)
            }
        }
    }
    
    private func setupView() {
        Service.setupNavBar(controller: self)
        self.navigationItem.title = "Summary"
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
    
   
    private func setupSummaryTableViewSpecifics() {
        summaryTableView.delegate = self
        summaryTableView.dataSource = self
        summaryTableView.rowHeight = 44
        summaryTableView.isScrollEnabled = false
        summaryTableView.allowsSelection = true
        summaryTableView.register(GraphDateEntryCell.self, forCellReuseIdentifier: "graphDateEntry")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isLoadingViewController {
            isLoadingViewController = false
        } else {
            setupView()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfDateOptions
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateF : DateFormatter = DateFormatter()
        dateF.dateFormat = "dd/MM/yyyy"
        dateF.timeZone = TimeZone(abbreviation: "Pacific/Auckland")
        let date = Date()
        let dateS = dateF.string(from: date)
        
        if (indexPath.row == 0) {
            let cell = self.summaryTableView.dequeueReusableCell(withIdentifier: "graphDateEntry") as! GraphDateEntryCell
            cell.textFieldName = "From"
            cell.textFieldValue = dateS
            cell.accessoryType = .disclosureIndicator
            cell.layoutSubviews()
            return cell
        } else {
            let cell = self.summaryTableView.dequeueReusableCell(withIdentifier: "graphDateEntry") as! GraphDateEntryCell
            cell.textFieldName = "To"
            cell.textFieldValue = dateS
            cell.accessoryType = .disclosureIndicator
            cell.layoutSubviews()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.black
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
        lineModelData.removeAll()
        
        print("Attempting to find data between \(date1) and \(date2)")
        //get hours between two dates for x axis scale
        let diff = date2.timeIntervalSince(date1)
        let hours = Int(diff) / 3600
        xAxisScale = Double(hours)
        print("Setting xAxis scale = \(xAxisScale)")
        
        //reformat dates so we can pull data
        let dateF : DateFormatter = DateFormatter()
        dateF.dateFormat = "yyyy-MMM-dd"
        dateF.timeZone = TimeZone(abbreviation: "Pacific/Auckland")
        let dateFromS = dateF.string(from: date1)
        let dateToS = dateF.string(from: date2)
        
        if Auth.auth().currentUser != nil {
            if let uid = Auth.auth().currentUser?.uid {
                
                var wrappers: [LogWrapper] = []
                
                let painRef = Database.database().reference(withPath: "pain").child(uid)
                //Refresh data and ignore cache
                painRef.keepSynced(true)
                /*
                 Note to self: need to use orderby if using querystarting and queryending...
                */
                painRef.queryOrderedByKey().queryStarting(atValue: dateFromS).queryEnding(atValue: dateToS).observeSingleEvent(of: .value) { (snapshot) in
                    
                   if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    
                    if snapshots.count == 0 {
                        let banner = NotificationBanner(title: "No Data for Specified Period", subtitle: "Try entering some data to view a summary...", style: .warning)
                        print("There was no data in the time period")
                        banner.show()
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
                                            wrappers.append(w)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    // Have all the data needed to build out graph
                    self.buildDailyChart(wrappers)
                }
            }
        }
    }
    
    fileprivate func buildDailyChart(_ wrappers: [LogWrapper]) {
        
        var mappedWrappers : Dictionary<String, [LogWrapper]> = Dictionary()
        for item in wrappers {
            if mappedWrappers[item.getType()] != nil {
                mappedWrappers[item.getType()]?.append(item)
                
            } else {
                mappedWrappers.updateValue([item], forKey: item.getType())
            }
        }
        //Get into correct format for graphing
        for area in mappedWrappers {
            
            //Create a linedatawrapper to hold info
            let lineData = LineDataWrapper()
            
            //So that it has somewhere to draw from on the axis
            var dataHolder = [(Double,Double)]()
            dataHolder.append((0.0,0.0))
            
            for item in area.value {
                lineData.setType(item.getType())
                //need a way of plotting it on a scale of 0-24
                
                //print("Items time \(item.getTime())")
                guard let dateFrom = startDate else { return }
                guard let dateTo = item.getTime().toDate() else { return }
            
                
                //print("Start date \(dateFrom)")
                //print("End date \(dateTo.date)")
                
                
                let difference = getDaysBetweenDates(firstDate: dateFrom, secondDate: dateTo.date)
    
                //print("Difference \(difference)")
                
                let doubleTime: Double = getDoubleFromTimeString(input: item.getTime(), difference: Double(difference))
                let doubleRating = Double(item.getRating())
                dataHolder.append((doubleTime, doubleRating))
            }
            
            lineData.setLineModelData(dataHolder)
            lineModelData.append(lineData)
        }
        //INIT CHART
        //view.backgroundColor = UIColor.black
        guard let chart = chart else {return}
        for view in chart.view.subviews {
            view.removeFromSuperview()
        }
        self.initChart()
        chart.view.setNeedsDisplay()
        self.setupChartKey()
    }
    
    /**
        A function that takes two dates and does a comparison using
        a granularity level of days.
     
        - parameter : firstDate, the first date.
        - parameter : secondDate, the second date.
        - returns: an Int representing the difference in days.
     */
    private func getDaysBetweenDates(firstDate: Date, secondDate: Date) -> Int {
        return secondDate.compare(toDate: firstDate, granularity: .day).rawValue
    }
    
    
    /**
        Implemented as it allows us to investigate the keyContainers
        subviews (a variable amount of UITextViews) representing chart
        keys for types of pain logged. Once identified we remove them
        so that they can be dynamically redrawn when the user opens the
        tab again.
     
        - parameter : animated, a default boolean.
     */
    override func viewDidDisappear(_ animated: Bool) {
        for item in keyContainer.subviews {
            item.removeFromSuperview()
        }
    }
    
    /**
        Sets up the chart keys via investigating the map which holds the
        color associated with a pain type (which is random at generation)
        and the pain types name.
     */
    private func setupChartKey() {
        var yCounter : CGFloat = 0.0
        for item in typeKeyMap {
            let someFrame = CGRect(x: 30.0, y: yCounter, width: 750, height: 30.0)
            let newTextField = UITextField(frame: someFrame)
            newTextField.text = item.key
            newTextField.textColor = item.value
            newTextField.allowsEditingTextAttributes = false
            keyContainer.addSubview(newTextField)
            yCounter = yCounter + 20
        }
    }
    
    /**
        A utility method used to format the input date into a double value
        that represents the time in 24 hour format.
     
        - parameter : input, an input String
        - returns: Double, the double value of the String
    */
    private func getDoubleFromTimeString(input: String, difference: Double) -> Double {
        let timeSplit = input.split(separator: " ")
        let timeIWant = timeSplit[1].dropLast(3).replacingOccurrences(of: ":", with: ".")
        let timeDouble = Double(timeIWant)
        guard let unwrappedTime = timeDouble else { return 0.0 }
        //IF WE HAVE 10.35 , how do we then scale this
        //let scale = Int(xAxisScale*60)
        let adjustment = (24*difference) + unwrappedTime
        
        return adjustment
    }
    
    /**
        Initialises and builds the chart, based on the template code
        suggested for doing so, with some tweaks that allow us to dynamically
        graph the associated pain and levels of pain over a period of time.
     
        link to template code: https://github.com/i-schuetz/SwiftCharts/blob/master/Examples/Examples/RangedAxisExample.swift
    */
    private func initChart() {
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont, fontColor: UIColor.white)
        guard let scale = xAxisScale else { return }
        let firstMin: Double = 0
        let lastMin: Double = scale
        
        //TODO transform data so its always within a scale of 24...
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // 1st x-axis model: Has an axis value (tick) for each year. We use this for the small x-axis dividers.
        
        //We need to set this dynamically? Potentially
        let divisor : Int
        
        //scale/24
        
        
        print("Multiple \((scale/24)-1)")
        let xValuesGenerator = ChartAxisGeneratorMultiplier(scale/24)
        print("Multiplier \(scale/24)")
        
        
        var labCopy = labelSettings
        labCopy.fontColor = UIColor.red
        let xEmptyLabelsGenerator = ChartAxisLabelsGeneratorFunc {value in return
            ChartAxisLabel(text: "", settings: labCopy)
        }
        
        let xModel = ChartAxisModel(lineColor: UIColor.red, firstModelValue: firstMin, lastModelValue: lastMin, axisTitleLabels: [], axisValuesGenerator: xValuesGenerator, labelsGenerator:
            xEmptyLabelsGenerator)
        //This is essentially do get rid of vertial lines as we cannot set it to nil
        let customXModel = ChartAxisModel(lineColor: UIColor.white, firstModelValue: 0, lastModelValue: 0, axisTitleLabels: [], axisValuesGenerator: xValuesGenerator, labelsGenerator:
            xEmptyLabelsGenerator)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // 2nd x-axis model: Has an axis value (tick) for each <rangeSize>/2 years. We use this to show the x-axis labels
        
        let rangeSize: Double = view.frame.width < view.frame.height ? 12 : 6 // adjust intervals for orientation
        let rangedMult: Double = rangeSize/2

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        /*
         Baz/Harry
         28th July 2018 - Made executive decision not to label ranges,
         as it is obvious given the giant date picker below the graph.
         */
        let xRangedLabelsGenerator = ChartAxisLabelsGeneratorFunc {value -> ChartAxisLabel in
            return ChartAxisLabel(text: "", settings: labelSettings)
        }

        let xValuesRangedGenerator = ChartAxisGeneratorMultiplier(rangedMult)

        let xModelForRanges = ChartAxisModel(lineColor: UIColor.white, firstModelValue: firstMin, lastModelValue: lastMin, axisTitleLabels: [], axisValuesGenerator: xValuesRangedGenerator, labelsGenerator: xRangedLabelsGenerator)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // 3rd x-axis model: Has an axis value (tick) for each <rangeSize> years. We use this to show the x-axis guidelines and long dividers
        
        let xValuesGuidelineGenerator = ChartAxisGeneratorMultiplier(rangeSize)
        let xModelForGuidelines = ChartAxisModel(lineColor: UIColor.white, firstModelValue: firstMin, lastModelValue: lastMin, axisTitleLabels: [], axisValuesGenerator: xValuesGuidelineGenerator, labelsGenerator: xEmptyLabelsGenerator)
        
        
        ////////////////////////////////////////////////////////////////////////////////////
        // y-axis model: Has an axis value (tick) for each 2 units. We use this to show the y-axis dividers, labels and guidelines.
        
        let generator = ChartAxisGeneratorMultiplier(1)
        let labelsGenerator = ChartAxisLabelsGeneratorFunc {scalar in
            return ChartAxisLabel(text: "\(scalar)", settings: labelSettings)
        }
        
        let yModel = ChartAxisModel(lineColor: UIColor.white, firstModelValue: 0, lastModelValue: 5, axisTitleLabels: [], axisValuesGenerator: generator, labelsGenerator: labelsGenerator)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Chart frame, settings
        
        let chartFrame = ExamplesDefaults.chartFrame(chartContainer.bounds)
        
        var chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        
        chartSettings.axisStrokeWidth = 0.5
        chartSettings.labelsToAxisSpacingX = 10
        chartSettings.leading = -1
        chartSettings.trailing = 40
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // In order to transform the axis models into axis layers, and get the chart inner frame size, we need to use ChartCoordsSpace.
        // Note that in the case of the x-axes we need to use ChartCoordsSpace multiple times - each of these axes represent essentially the same x-axis, so we can't use multi-axes functionality (i.e. pass an array of x-axes to ChartCoordsSpace).
        
        let coordsSpace = ChartCoordsSpaceRightBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let coordsSpaceForRanges = ChartCoordsSpaceRightBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModelForRanges, yModel: yModel)
        let coordsSpaceForGuidelines = ChartCoordsSpaceRightBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModelForGuidelines, yModel: yModel)
        let customCoordsSpaceForGuidelines = ChartCoordsSpaceRightBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: customXModel, yModel: yModel)
        
        var (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        var (xRangedAxisLayer, _, _) = (coordsSpaceForRanges.xAxisLayer, coordsSpaceForRanges.yAxisLayer, coordsSpaceForRanges.chartInnerFrame)
        let (xGuidelinesAxisLayer, _, _) = (coordsSpaceForGuidelines.xAxisLayer, coordsSpaceForGuidelines.yAxisLayer, coordsSpaceForGuidelines.chartInnerFrame)
        let customXaxisLayer = customCoordsSpaceForGuidelines.xAxisLayer
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Lines layer -- THIS IS WHERE WE MODIFY THE LINE DATA
        var lineModels = [ChartLineModel]()
        
        for item in lineModelData {
            let randColor = UIColor.random()
            //Store color for key later
            typeKeyMap.updateValue(randColor, forKey: item.getType())

            let lineChartPoints = item.getLineModelData().map{ChartPoint(x: ChartAxisValueDouble($0.0), y: ChartAxisValueDouble($0.1))}
            let lineModel = ChartLineModel(chartPoints: lineChartPoints, lineColor: randColor, lineWidth: 2, animDuration: 1, animDelay: 0)
            lineModels.append(lineModel)
            
        }
        
        let chartPointsLineLayer = ChartPointsLineLayer<ChartPoint>(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: lineModels, pathGenerator: CubicLinePathGenerator(tension1: 0.2, tension2: 0.2))

        // Finally we set a custom clip rect for the view where we display the markers, in order to not show them outside of the chart's boundaries, during zooming and panning. For now the size is hardcoded. This should be improved. Until then you can calculate the exact frame using the spacing settings and label (string) sizes.
        chartSettings.customClipRect = CGRect(x: 0, y: chartSettings.top, width: view.frame.width, height: view.frame.height - 120)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Guidelines layer. Note how we pass the x-axis layer we created specifically for the guidelines.
        
        let guidelinesLayerSettings = ChartGuideLinesLayerSettings(linesColor: UIColor.white, linesWidth: 0.3)
    
        let guidelinesLayer = ChartGuideLinesLayer(xAxisLayer: customXaxisLayer, yAxisLayer: yAxisLayer, settings: guidelinesLayerSettings)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Dividers layer with small lines. This is used both in x and y axes
        let dividersSettings =  ChartDividersLayerSettings(linesColor: UIColor.white, linesWidth: 1, start: 2, end: 0)
        let dividersLayer = ChartDividersLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, axis: .xAndY, settings: dividersSettings)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Disable frame updates for 2 of the 3 x-axis layers. This way the space will not be reserved multiple times. We need this only because the 3 layers represent the same x-axis (for a multi-axis chart this would not be necessary). Note that it's important to pass all 3 layers to the chart, although only one is actually visible, because otherwise the layers will not receive inner frame updates, which results in any layers that reference these layers not being positioned correctly.
        xRangedAxisLayer.canChangeFrameSize = false
        xAxisLayer.canChangeFrameSize = false
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // create chart instance with frame and layers
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                xRangedAxisLayer,
                xGuidelinesAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                chartPointsLineLayer,
                dividersLayer,
                //dividersLayer2
            ]
        )
        view.addSubview(chart.view)
        self.chart = chart
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.didLayout {
            self.didLayout = true
            self.initChart()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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


