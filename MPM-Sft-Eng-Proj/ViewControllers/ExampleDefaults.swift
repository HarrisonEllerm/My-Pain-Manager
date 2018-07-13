//
//  exampleDefaults.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Sebastian Peden on 29/06/18.
//  Copyright © 2018 Sebastian Peden. All rights reserved.
import UIKit
import SwiftCharts

// Adapted from gitHub

struct ExamplesDefaults {
    static var chartSettings: ChartSettings {
            return iPhoneChartSettings
        
    }
    static var chartSettingsWithPanZoom: ChartSettings {
            return iPhoneChartSettingsWithPanZoom
        
    }
    fileprivate static var iPhoneChartSettings: ChartSettings {
        var chartSettings = ChartSettings()
        chartSettings.leading = 10
        chartSettings.top = 10
        chartSettings.trailing = 10
        chartSettings.bottom = 10
        chartSettings.labelsToAxisSpacingX = 5
        chartSettings.labelsToAxisSpacingY = 5
        chartSettings.axisTitleLabelsToLabelsSpacing = 4
        chartSettings.axisStrokeWidth = 0.2
        chartSettings.spacingBetweenAxesX = 1
        chartSettings.spacingBetweenAxesY = 8
        chartSettings.labelsSpacing = 0
        return chartSettings
    }
    
    fileprivate static var iPhoneChartSettingsWithPanZoom: ChartSettings {
        var chartSettings = iPhoneChartSettings
        chartSettings.zoomPan.panEnabled = true
        chartSettings.zoomPan.zoomEnabled = true
        return chartSettings
    }
    
    static func chartFrame(_ containerBounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 100, width: containerBounds.size.width, height: containerBounds.size.height*0.8 )//- 70)
    }
    
    static var labelSettings: ChartLabelSettings {
        return ChartLabelSettings(font: ExamplesDefaults.labelFont)
    }
    
    static var labelFont: UIFont {
        return ExamplesDefaults.fontWithSize(11)
    }
    
    static var labelFontSmall: UIFont {
        return ExamplesDefaults.fontWithSize(10)
    }
    
    static func fontWithSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static var guidelinesWidth: CGFloat {
        return 0.1
    }
    
    static var minBarSpacing: CGFloat {
        return 5
    }
}
