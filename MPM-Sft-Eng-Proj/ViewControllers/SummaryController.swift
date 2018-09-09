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
import SwiftyBeaver
import SwiftSpinner
import CalendarDateRangePickerViewController
import NVActivityIndicatorView

class SummaryController: UIViewController {

    private var didLayout: Bool = false
    private let numberOfDateOptions = 2
    private var scaleMultiplier: Double?
    private var startDate: Date?
    private var endDate: Date?
    private let log = SwiftyBeaver.self
    private var chartView: AAChartView?
    private var chartModel: AAChartModel?
    private var wrappers: [LogWrapper] = []
    private var chartElements = Array<Dictionary<String, Any>>()
    private var chartElementsHidden = Array<Dictionary<String, Any>>()
    private var datesInRange = [String]()
    private var _units = 24.0
    private var _factor = 20.0
    private var _graphContentOffSet: CGFloat = 40
    private var _graphFrameOffset: CGFloat = 15
    private var month: String?
    private var dateRangePickerViewController = CalendarDateRangePickerViewController()
    private var loading: NVActivityIndicatorView?
    private var noDataImageView: UIImageView?

    private var chartContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "Couldn't find any data!\nTry setting some dates."
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = UIColor.white
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        Service.setupNavBar(controller: self)
        self.navigationItem.title = "Summary"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Report", style: .done, target: self, action: #selector(handleReportButtonOnTap))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Dates", style: .done, target: self, action: #selector(handleDateRangeButtonOnTap))
        self.navigationController?.navigationBar.tintColor = UIColor(r: 254, g: 162, b: 25)
        view.backgroundColor = UIColor.black
        self.chartContainer.backgroundColor = UIColor.black
        view.addSubview(chartContainer)
        setupChartContainer()
        loading = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), type: .ballClipRotatePulse, color: UIColor.white, padding: 0)
        loading?.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        loading?.isHidden = true
        view.addSubview(loading!)
        setupNoDataSubView()
    }

    private func setupNoDataSubView() {
        noDataImageView = UIImageView(frame: CGRect(x: self.view.center.x - 50, y: self.view.center.y - 100, width: 100, height: 100))
        noDataImageView!.image = UIImage(named: "noData")
        self.view.addSubview(noDataImageView!)
        self.view.addSubview(noDataLabel)
        noDataLabel.topAnchor.constraint(equalTo: noDataImageView!.bottomAnchor).isActive = true
        noDataLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }

    @objc private func handleDateRangeButtonOnTap() {
        dateRangePickerViewController = CalendarDateRangePickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
        dateRangePickerViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: dateRangePickerViewController)
        navigationController.navigationBar.barTintColor = UIColor.black
        navigationController.navigationBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }

    //TODO
    @objc func handleReportButtonOnTap() {
    }

    private func getDataForMonth() {
        refreshData()
        if let sDate = startDate, let eDate = endDate {
            noDataLabel.isHidden = true
            self.noDataImageView?.isHidden = true
            loading?.isHidden = false
            loading?.startAnimating()
            if Auth.auth().currentUser != nil, let uid = Auth.auth().currentUser?.uid {
                let painRef = Database.database().reference(withPath: "pain").child(uid)
                //Refresh data and ignore cache
                painRef.keepSynced(true)
                painRef.child("\(sDate.year)").child("\(sDate.monthName(.short))").observeSingleEvent(of: .value) { (snapshot) in
                    self.log.debug("Inside first block")
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshots {
                            let date = snap.key
                            if let subchildren = snap.children.allObjects as? [DataSnapshot] {
                                for snap in subchildren {
                                    if let values = snap.value as? Dictionary<String, Any> {
                                        guard let rating: Double = values["ranking"] as? Double else { return }
                                        guard let type: String = values["type"] as? String else { return }
                                        let w = LogWrapper(date, rating, type)
                                        self.wrappers.append(w)
                                    }
                                }
                            }
                        }
                    }
                    //If they have selected a range which includes two months
                    if (sDate.month < eDate.month) {
                        self.log.debug("Inside second block")
                        painRef.child("\(sDate.year)").child("\(eDate.monthName(.short))").observeSingleEvent(of: .value) { (snapshot) in
                            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                                for snap in snapshots {
                                    let date = snap.key
                                    if let subchildren = snap.children.allObjects as? [DataSnapshot] {
                                        for snap in subchildren {
                                            if let values = snap.value as? Dictionary<String, Any> {
                                                guard let rating: Double = values["ranking"] as? Double else { return }
                                                guard let type: String = values["type"] as? String else { return }
                                                let w = LogWrapper(date, rating, type)
                                                self.wrappers.append(w)
                                            }
                                        }
                                    }
                                }
                            }
                            if self.wrappers.count > 0 {
                                self.buildChart()
                            } else {
                                //There was no data in given period
                                self.loading?.stopAnimating()
                                self.loading?.isHidden = true
                                self.chartContainer.isHidden = true
                                self.noDataLabel.isHidden = false
                                self.noDataImageView?.isHidden = false
                            }
                        }
                    }
                }
            }
        } else {
            log.error("Start Date was nil even though it was set...")
        }
    }

    /**
        Refreshes the data associated with the graph. This is
        used when the view controller is presented after initially
        being presented via viewDidLoad.
    */
    private func refreshData() {
        chartElements.removeAll()
        datesInRange.removeAll()
        wrappers.removeAll()
    }


    /**
        Builds the chart out. Initially this function maps the logs to
        each of the corresponding body areas/muscle groups and then
        proceeds to call a function that sets up the x and y values for
        the graph. Finally, after all the data has been organised and mapped,
        the chart is initiated.
     */
    private func buildChart() {
        //Grouping the log wrappers by pain type
        var mappedWrappers: Dictionary<String, [LogWrapper]> = Dictionary()
        for item in self.wrappers {
            if mappedWrappers[item.getType()] != nil {
                mappedWrappers[item.getType()]?.append(item)
            } else {
                mappedWrappers.updateValue([item], forKey: item.getType())
            }
        }
        //Setup the graphs x and y values
        setupXandYValues(wrappers: mappedWrappers)
        //Initiate the chart
        initChart()
    }

    /**
        A function that sets up the linedata for a particular area. This essentially
        calculates the x and y values for the graph. The calculation of the y values
        is as follows:
     
            e.g. a given date range of 05-Sep-2018 to 10-Sep-2018
     
        X: We get every day between the given period and place it into an array called
           datesInRange. This is used as the x axis values.
     
                Here the array would look like ["5","6","7","8","9","10"]
     
        Y: For each type of pain logged over the period a x axis series is created. These
           logs need to line up with the corresponding X axis values. If there is no log
           corresponding to the x axis value, a 0 is inserted.
     
           e.g. "Back" which had a log of 4 on the 5th, 3 on the 6th, 5 on the 8th and 1
           on the 10th.
     
            The corresponding series would look like: [4,3,0,5,0,1]
     
        For situations where there are more than one log per day per body part, for the
        purposes of graphing we are calculating an incremental average. This simplifies
        the graphing process and allows us to keep the fine granularity of detail within
        the database. The equations and logic for our calculation can be found here:
     
            https://math.stackexchange.com/questions/106700/incremental-averageing
     
        - parameter : wrappers, a dictionary of mapped wrappers, where all logs for a
                      particular area/muscle group are grouped together.
     */
    private func setupXandYValues(wrappers: Dictionary<String, [LogWrapper]>) {
        log.debug("Setting up X and Y Values")
        var lineModelData = [LineDataWrapper]()
        //Setup the xValues for the period
        guard var start = startDate, let end = endDate else { return }
        let cal = Calendar.current

        datesInRange.append(String(start.day))
        while start <= end - 1 {
            start = cal.date(byAdding: .day, value: 1, to: start)!
            datesInRange.append(String(start.day))
        }
        //Setup the yValues for the period
        for area in wrappers {
            let lineData = LineDataWrapper()
            var yValues: Array<Double> = Array(repeating: 0, count: datesInRange.count)
            var yValuesCount: Array<Int> = Array(repeating: 1, count: datesInRange.count)
            for log in area.value {
                let xValue = String(log.getTime().suffix(2))
                if let index = datesInRange.index(of: xValue) {
                    let prevMean = yValues[index]
                    let count = yValuesCount[index]
                    //This logic exists due to te fatigue and pain scales
                    //differing. Pain is rated on a scale of 0-5 whereas
                    //fatigue is rated on a scale of 0-100.
                    var newValue: Double
                    if log.getType() == "General Fatigue" {
                        newValue = log.getRating()
                    } else {
                        newValue = log.getRating() * _factor
                    }
                    let newMean = (prevMean * (Double(count - 1)) + newValue) / Double(count)
                    yValues[index] = newMean
                    yValuesCount[index] = count + 1
                }
            }
            lineData.setLineModelData(yValues)
            lineData.setType(area.key)
            lineModelData.append(lineData)
        }
        //Finally, create the series element
        for item in lineModelData {
            let series = AASeriesElement().name(item.getType()).data(item.getLineModelData())
            chartElements.append(series.toDic()!)
        }
    }

    private func initChart() {
        let chartViewWidth = self.chartContainer.frame.size.width
        let chartViewHeight = self.chartContainer.frame.size.height
        chartView = AAChartView()
        if let chartV = chartView {
            chartV.frame = CGRect(x: 0, y: 0, width: chartViewWidth, height: chartViewHeight)
            chartV.center = CGPoint(x: self.chartContainer.frame.size.width / 2, y: self.chartContainer.frame.size.height / 2)
            chartV.isClearBackgroundColor = true
            chartV.contentHeight = chartViewHeight
            chartV.scrollEnabled = false
            chartContainer.addSubview(chartV)
            chartModel = AAChartModel.init()
                .chartType(AAChartType.Line)
                .animationType(AAChartAnimationType.Bounce)
                .dataLabelEnabled(false)
                .categories(self.datesInRange)
                .colorsTheme(["#fe117c", "#ffc069", "#06caf4", "#7dffc0"])
                .backgroundColor("#030303")
                .series(chartElements)
            if let chartM = chartModel {
                loading?.stopAnimating()
                loading?.isHidden = true
                self.chartContainer.isHidden = false
                chartV.aa_drawChartWithChartModel(chartM)
            }
        }
    }

    private func setupChartContainer() {
        chartContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        chartContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        chartContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        chartContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
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
    let rating: Double
    let type: String

    init(_ time: String, _ rating: Double, _ type: String) {
        self.time = time
        self.rating = rating
        self.type = type
    }

    func getTime() -> String {
        return self.time
    }

    func getRating() -> Double {
        return self.rating
    }

    func getType() -> String {
        return self.type
    }
}

/**
    A wrapper object that holds the x
    co-ordinates for a item being plotted, as well
    as the type of pain associated with that value.
 */
private class LineDataWrapper {

    var lineModelData = [(Double)]()
    var type: String = ""

    func setType(_ type: String) {
        self.type = type
    }

    func getType() -> String {
        return self.type
    }

    func getLineModelData() -> [(Double)] {
        return self.lineModelData
    }

    func setLineModelData(_ model: [(Double)]) {
        self.lineModelData = model
    }
}

extension SummaryController: CalendarDateRangePickerViewControllerDelegate {

    func didTapCancel() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    func didTapDoneWithDateRange(startDate: Date!, endDate: Date!) {
        //Format date to be in correct timezone
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "Pacific/Auckland")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        self.startDate = dateFormatter.string(from: startDate).toDate("dd/MM/yyyy")?.date
        self.endDate = dateFormatter.string(from: endDate).toDate("dd/MM/yyyy")?.date
       //Enforce one month max period for viewing summary data
       //If there is either 0 months or 1 months difference in dates
       if (endDate.month - startDate.month < 2) {
            //case 2 when end date day is less than the start date day
            if endDate.date.day > startDate.date.day {
                //change the endDate
                self.endDate = startDate.add(TimeChunk(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 1, years: 0))
                dateRangePickerViewController.selectedEndDate = self.endDate
                dateRangePickerViewController.collectionView?.reloadData()
                return
            }
        //More than one months difference, must adjust always
       } else {
            self.endDate = startDate.add(TimeChunk(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 1, years: 0))
            dateRangePickerViewController.selectedEndDate = self.endDate
            dateRangePickerViewController.collectionView?.reloadData()
            return
        }
        self.navigationController?.dismiss(animated: true, completion: nil)
        getDataForMonth()
    }
}





