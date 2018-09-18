//
//  TimeEntryCellDelegate.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Sebastian Peden on 9/18/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//


import Foundation
import UIKit

protocol TimeEntryCellDelegate {
    func textFieldInCell(didSelect cell: TimeEntryCell)
    func textFieldInCell(cell: TimeEntryCell, editingChangedInTextField newText:String)
}
