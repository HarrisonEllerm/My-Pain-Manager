//
//  TextEntryCellDelegate.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 1/05/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import UIKit

protocol DateEntryCellDelegate {
    func textFieldInCell(didSelect cell:DateEntryCell)
    func textFieldInCell(cell:DateEntryCell, editingChangedInTextField newText:String)
}
