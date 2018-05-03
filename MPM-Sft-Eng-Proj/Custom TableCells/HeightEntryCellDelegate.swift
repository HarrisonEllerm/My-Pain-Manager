//
//  HeightEntryCellDelegate.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 3/05/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import Foundation
import UIKit

protocol HeightEntryCellDelegate {
    func textFieldInCell(didSelect cell:HeightEntryCell)
    func textFieldInCell(cell:HeightEntryCell, editingChangedInTextField newText:String)
}
