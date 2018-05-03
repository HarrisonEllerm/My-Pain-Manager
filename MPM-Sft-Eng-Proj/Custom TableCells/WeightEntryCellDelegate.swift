//
//  WeightEntryCellDelegate.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 3/05/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import Foundation
import UIKit

protocol WeightEntryCellDelegate {
    func textFieldInCell(didSelect cell:WeightEntryCell)
    func textFieldInCell(cell:WeightEntryCell, editingChangedInTextField newText:String)
}
