//
//  GraphDateEntryCellDelegate.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 28/07/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import UIKit

protocol GraphDateEntryCellDelegate {
    func textFieldInCell(didSelect cell:GraphDateEntryCell)
    func textFieldInCell(cell:GraphDateEntryCell, editingChangedInTextField newText:String)
}
