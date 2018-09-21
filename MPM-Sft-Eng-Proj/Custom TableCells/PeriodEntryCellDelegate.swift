//
//  PeriodEntryCellDelegate.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 21/09/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import Foundation

protocol PeriodEntryCellDelegate {
    func textFieldInCell(cell:PeriodEntryCell, editingChangedInTextField newText:String)
}
