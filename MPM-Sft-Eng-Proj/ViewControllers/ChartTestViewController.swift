//
//  ChartTestViewController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 29/06/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SwiftCharts


class StackedBarsExample: UIViewController {
    
    fileprivate var chart: Chart? // arc
    
    let sideSelectorHeight: CGFloat = 50
    let alpha: CGFloat = 0.9//0.6
    
    fileprivate func chart(horizontal: Bool) -> Chart {
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let color0 = UIColor.gray.withAlphaComponent(alpha)
        let color1 = UIColor.blue.withAlphaComponent(alpha)
        let color2 = UIColor.red.withAlphaComponent(alpha)
        let color3 = UIColor.green.withAlphaComponent(alpha)
        
        let zero = ChartAxisValueDouble(0)
        let barModels = [
            ChartStackedBarModel(constant: ChartAxisValueString("01", order: 1, labelSettings: labelSettings), start: zero, items: [
                ChartStackedBarItemModel(quantity: 2, bgColor: color0),
                ChartStackedBarItemModel(quantity: 6, bgColor: color1),
                ChartStackedBarItemModel(quantity: 3, bgColor: color2),
                ChartStackedBarItemModel(quantity: 2, bgColor: color3)
                ]),
            ChartStackedBarModel(constant: ChartAxisValueString("02", order: 2, labelSettings: labelSettings), start: zero, items: [
                ChartStackedBarItemModel(quantity: 4, bgColor: color0),
                ChartStackedBarItemModel(quantity: 3, bgColor: color1),
                ChartStackedBarItemModel(quantity: 1, bgColor: color2),
                ChartStackedBarItemModel(quantity: 3, bgColor: color3)
                ]),
            ChartStackedBarModel(constant: ChartAxisValueString("03", order: 3, labelSettings: labelSettings), start: zero, items: [
                ChartStackedBarItemModel(quantity: 3, bgColor: color0),
                ChartStackedBarItemModel(quantity: 5, bgColor: color1),
                ChartStackedBarItemModel(quantity: 2, bgColor: color2),
                ChartStackedBarItemModel(quantity: 1, bgColor: color3)
                ]),
            ChartStackedBarModel(constant: ChartAxisValueString("04", order: 4, labelSettings: labelSettings), start: zero, items: [
                ChartStackedBarItemModel(quantity: 1, bgColor: color0),
                ChartStackedBarItemModel(quantity: 3, bgColor: color1),
                ChartStackedBarItemModel(quantity: 5, bgColor: color2),
                ChartStackedBarItemModel(quantity: 5, bgColor: color3)
                ])
        ]
        
        let (axisValues1, axisValues2) = (
            stride(from: 0, through: 40, by: 10).map {ChartAxisValueDouble(Double($0), labelSettings: labelSettings)},
            [ChartAxisValueString("", order: 0, labelSettings: labelSettings)] + barModels.map{$0.constant} + [ChartAxisValueString("", order: 5, labelSettings: labelSettings)]
        )
        let (xValues, yValues) = horizontal ? (axisValues1, axisValues2) : (axisValues2, axisValues1)
        
        var xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Time/Date", settings: labelSettings))
        var yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Pain/Lethargy level", settings: labelSettings.defaultVertical()))
        
        if horizontal{
            xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Pain Level", settings: labelSettings))
            yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Time/Date", settings: labelSettings.defaultVertical()))
        
        }
        else{
            xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Time/Date", settings: labelSettings))
            yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Pain Level", settings: labelSettings.defaultVertical()))
        }
        
        
        let frame = ExamplesDefaults.chartFrame(view.bounds)
        let chartFrame = chart?.frame ?? CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.height - sideSelectorHeight)
        
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let barViewSettings = ChartBarViewSettings(animDuration: 0.5)
        let chartStackedBarsLayer = ChartStackedBarsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, innerFrame: innerFrame, barModels: barModels, horizontal: horizontal, barWidth: 40, settings: barViewSettings, stackFrameSelectionViewUpdater: ChartViewSelectorAlpha(selectedAlpha: 1, deselectedAlpha: alpha)) {tappedBar in
            
            guard let stackFrameData = tappedBar.stackFrameData else {return}
            
            let chartViewPoint = tappedBar.layer.contentToGlobalCoordinates(CGPoint(x: tappedBar.barView.frame.midX, y: stackFrameData.stackedItemViewFrameRelativeToBarParent.minY))!
            let viewPoint = CGPoint(x: chartViewPoint.x, y: chartViewPoint.y + 70)
            let infoBubble = InfoBubble(point: viewPoint, preferredSize: CGSize(width: 50, height: 40), superview: self.view, text: "\(stackFrameData.stackedItemModel.quantity)", font: ExamplesDefaults.labelFont, textColor: UIColor.white, bgColor: UIColor.black)
            infoBubble.tapHandler = {
                infoBubble.removeFromSuperview()
            }
            self.view.addSubview(infoBubble)
        }
        
        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: settings)
        
        return Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                chartStackedBarsLayer
            ]
        )
    }
    
    fileprivate func showChart(horizontal: Bool) {
        self.chart?.clearView()
        
        let chart = self.chart(horizontal: horizontal)
        view.addSubview(chart.view)
        self.chart = chart
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        view.backgroundColor = .white
        
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        let nameOfMonth = dateFormatter.string(from: now)
        
        navigationItem.title = "My Pain Chart for \(nameOfMonth)"

        showChart(horizontal: false)
        if let chart = chart {
            let sideSelector = DirSelector(frame: CGRect(x: 0, y: chart.frame.origin.y + chart.frame.size.height, width: view.frame.size.width, height: sideSelectorHeight), controller: self)
            view.addSubview(sideSelector)
        }
        
        
        //For each pain thats been logged
        let button1 = UIButton()
        button1.frame = CGRect(x: self.view.frame.size.width - 60, y: 100, width: 60, height: 30)
        button1.backgroundColor = UIColor.gray.withAlphaComponent(alpha)
        button1.setTitle("Paintype1", for: .normal)
         button1.titleLabel?.adjustsFontSizeToFitWidth = true
        self.view.addSubview(button1)
        
        let button2 = UIButton()
        button2.frame = CGRect(x: self.view.frame.size.width - 120, y: 100, width: 60, height: 30)
        button2.backgroundColor = UIColor.blue.withAlphaComponent(alpha)
        button2.setTitle("Paintype2", for: .normal)
        button2.titleLabel?.adjustsFontSizeToFitWidth = true
        self.view.addSubview(button2)
        
        let button3 = UIButton()
        button3.frame = CGRect(x: self.view.frame.size.width - 180, y: 100, width: 60, height: 30)
        button3.backgroundColor = UIColor.red.withAlphaComponent(alpha)
        button3.setTitle("Paintype3", for: .normal)
        button3.titleLabel?.adjustsFontSizeToFitWidth = true
        self.view.addSubview(button3)
        
        let button4 = UIButton()
        button4.frame = CGRect(x: self.view.frame.size.width - 240, y: 100, width: 60, height: 30)
        button4.backgroundColor = UIColor.green.withAlphaComponent(alpha)
        button4.setTitle("Paintype4", for: .normal)
        button4.titleLabel?.adjustsFontSizeToFitWidth = true
        self.view.addSubview(button4)
        
  
        
        
        
    }
    
    class DirSelector: UIView {
        
        let horizontal: UIButton
        let vertical: UIButton
        
        weak var controller: StackedBarsExample?
        
        fileprivate let buttonDirs: [UIButton : Bool]
        
        init(frame: CGRect, controller: StackedBarsExample) {
            
            self.controller = controller
            
            self.horizontal = UIButton()
            self.horizontal.setTitle("Horizontal", for: UIControlState())
            self.vertical = UIButton()
            self.vertical.setTitle("Vertical", for: UIControlState())
            
            self.buttonDirs = [horizontal: false, vertical: true]
            
            super.init(frame: frame)
            
            addSubview(vertical)
            addSubview(horizontal)
           
            
            for button in [horizontal, vertical] {
                button.titleLabel?.font = ExamplesDefaults.fontWithSize(14)
                button.setTitleColor(UIColor.blue, for: UIControlState())
                button.addTarget(self, action: #selector(DirSelector.buttonTapped(_:)), for: .touchUpInside)
            }
        }
        
        @objc func buttonTapped(_ sender: UIButton) {
            let horizontal = sender == self.horizontal ? true : false
            controller?.showChart(horizontal: horizontal)
        }
        
        override func didMoveToSuperview() {
            let views = [horizontal, vertical]
            for v in views {
                v.translatesAutoresizingMaskIntoConstraints = false
            }
            
            let namedViews = views.enumerated().map{index, view in
                ("v\(index)", view)
            }
            
            var viewsDict = Dictionary<String, UIView>()
            for namedView in namedViews {
                viewsDict[namedView.0] = namedView.1
            }
            
            let buttonsSpace: CGFloat = 10
            
            let hConstraintStr = namedViews.reduce("H:|") {str, tuple in
                "\(str)-(\(buttonsSpace))-[\(tuple.0)]"
            }
            
            let vConstraits = namedViews.flatMap {NSLayoutConstraint.constraints(withVisualFormat: "V:|[\($0.0)]", options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict)}
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: hConstraintStr, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict)
                + vConstraits)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

