//
//  PeriodEntryCellDelegate.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Sebastian Peden on 9/18/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import Foundation

import UIKit

protocol PeriodEntryCellDelegate {
    func textFieldInCell(didSelect cell:PeriodEntryCell)
    func textFieldInCell(cell:PeriodEntryCell, editingChangedInTextField newText:String)
}
