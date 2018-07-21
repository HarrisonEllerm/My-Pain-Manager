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

class SummaryController: UIViewController {
    
    private var chart: Chart? // arc
    private var didLayout: Bool = false
    private var lineModelData = [LineDataWrapper]()
    private var typeKeyMap = Dictionary<String, UIColor>()
    
    let chartContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Service.setupNavBar(controller: self)
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        let nameOfMonth = dateFormatter.string(from: now)
        self.navigationItem.title = "My Pain Chart for \(nameOfMonth)"
        
        view.addSubview(chartContainer)
        setupChartContainer()
        getDataForTimePeriod()
        
    }
    
    private func getDataForTimePeriod() {
        
        let dateF : DateFormatter = DateFormatter()
        dateF.dateFormat = "yyyy-MMM-dd"
        dateF.timeZone = TimeZone(abbreviation: "Pacific/Auckland")
        let date = Date()
        let dateS = dateF.string(from: date)
        print("Date s: \(dateS)")
        
        if Auth.auth().currentUser != nil {
            if let uid = Auth.auth().currentUser?.uid {
                
                var wrappers: [Wrapper] = []
                let painRef = Database.database().reference(withPath: "pain").child(uid)
                
                painRef.child(dateS).observeSingleEvent(of: .value) { (snapshot) in
                   
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshots {
                            
                            if let values = snap.value as? Dictionary<String, Any> {
                                let time = dateS + " " + snap.key
                                guard let rating : Int = values["ranking"] as? Int else { return }
                                guard let type : String = values["type"] as? String else { return }
                                
                                let w = Wrapper(time, rating, type)
                                wrappers.append(w)
                            }
                        }
                    }
                   self.buildDailyChart(wrappers)
                }
            }
        }
    }
    
    fileprivate func buildDailyChart(_ wrappers: [Wrapper]) {
        print("Building daily chart")
        var mappedWrappers : Dictionary<String, [Wrapper]> = Dictionary()
        
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
                let doubleTime: Double = getDoubleFromTimeString(input: item.getTime())
                let doubleRating = Double(item.getRating())
                dataHolder.append((doubleTime, doubleRating))
            }
            
            lineData.setLineModelData(dataHolder)
            lineModelData.append(lineData)
        }
        
        view.backgroundColor = UIColor.black
        guard let chart = chart else {return}
        for view in chart.view.subviews {
            view.removeFromSuperview()
        }
        self.initChart()
        chart.view.setNeedsDisplay()
        
    }
    
    /**
        A utility method used to format the input date into a double value
        that represents the time in 24 hour format.
    */
    private func getDoubleFromTimeString(input: String) -> Double {
        let timeSplit = input.split(separator: " ")
        let timeIWant = timeSplit[1].dropLast(3).replacingOccurrences(of: ":", with: ".")
        let timeDouble = Double(timeIWant)
        guard let unwrappedTime = timeDouble else { return 0.0 }
        return unwrappedTime
    }
    
    private func initChart() {
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont, fontColor: UIColor.white)
        
        let firstHour: Double = 0
        let lastHour: Double = 24
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // 1st x-axis model: Has an axis value (tick) for each year. We use this for the small x-axis dividers.
        
        let xValuesGenerator = ChartAxisGeneratorMultiplier(1)
        
        var labCopy = labelSettings
        labCopy.fontColor = UIColor.red
        let xEmptyLabelsGenerator = ChartAxisLabelsGeneratorFunc {value in return
            ChartAxisLabel(text: "", settings: labCopy)
        }
        
        let xModel = ChartAxisModel(lineColor: UIColor.white, firstModelValue: firstHour, lastModelValue: lastHour, axisTitleLabels: [], axisValuesGenerator: xValuesGenerator, labelsGenerator:
            xEmptyLabelsGenerator)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // 2nd x-axis model: Has an axis value (tick) for each <rangeSize>/2 years. We use this to show the x-axis labels
        
        let rangeSize: Double = view.frame.width < view.frame.height ? 12 : 6 // adjust intervals for orientation
        let rangedMult: Double = rangeSize / 2

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0

        let xRangedLabelsGenerator = ChartAxisLabelsGeneratorFunc {value -> ChartAxisLabel in
            if value < lastHour && value.truncatingRemainder(dividingBy: rangedMult) == 0 && value.truncatingRemainder(dividingBy: rangeSize) != 0 {
                let val1 = value - rangedMult
                let val2 = value + rangedMult
                return ChartAxisLabel(text: "\(String(format: "%.0f", val1)) - \(String(format: "%.0f", val2))", settings: labelSettings)
            } else {
                return ChartAxisLabel(text: "", settings: labelSettings)
            }
        }

        let xValuesRangedGenerator = ChartAxisGeneratorMultiplier(rangedMult)

        let xModelForRanges = ChartAxisModel(lineColor: UIColor.white, firstModelValue: firstHour, lastModelValue: lastHour, axisTitleLabels: [], axisValuesGenerator: xValuesRangedGenerator, labelsGenerator: xRangedLabelsGenerator)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // 3rd x-axis model: Has an axis value (tick) for each <rangeSize> years. We use this to show the x-axis guidelines and long dividers
        
        let xValuesGuidelineGenerator = ChartAxisGeneratorMultiplier(rangeSize)
        let xModelForGuidelines = ChartAxisModel(lineColor: UIColor.white, firstModelValue: firstHour, lastModelValue: lastHour, axisTitleLabels: [], axisValuesGenerator: xValuesGuidelineGenerator, labelsGenerator: xEmptyLabelsGenerator)
        
        
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
        
        var (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        var (xRangedAxisLayer, _, _) = (coordsSpaceForRanges.xAxisLayer, coordsSpaceForRanges.yAxisLayer, coordsSpaceForRanges.chartInnerFrame)
        let (xGuidelinesAxisLayer, _, _) = (coordsSpaceForGuidelines.xAxisLayer, coordsSpaceForGuidelines.yAxisLayer, coordsSpaceForGuidelines.chartInnerFrame)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Lines layer
        var lineModels = [ChartLineModel]()
        
        for item in lineModelData {
            
            print("Graphing: \(item.getType())")
            
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
        let guidelinesLayer = ChartGuideLinesLayer(xAxisLayer: xGuidelinesAxisLayer, yAxisLayer: yAxisLayer, settings: guidelinesLayerSettings)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Dividers layer with small lines. This is used both in x and y axes
        
        let dividersSettings =  ChartDividersLayerSettings(linesColor: UIColor.white, linesWidth: 1, start: 2, end: 0)
        let dividersLayer = ChartDividersLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, axis: .xAndY, settings: dividersSettings)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Dividers layer with long lines. This is used only in the x axis. Note how we pass the same axis layer we passed to the guidelines - we want to use the same intervals.
        
        let dividersSettings2 =  ChartDividersLayerSettings(linesColor: UIColor.white, linesWidth: 0.5, start: 30, end: 0)
        let dividersLayer2 = ChartDividersLayer(xAxisLayer: xGuidelinesAxisLayer, yAxisLayer: yAxisLayer, axis: .x, settings: dividersSettings2)
        
        
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
                dividersLayer2
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
        chartContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        chartContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: -20).isActive = true
        chartContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 20).isActive = true
        chartContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 20).isActive = true
    }
    
}


private class Wrapper {
    
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


