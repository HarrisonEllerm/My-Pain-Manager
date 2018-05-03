//
//  GenderEntryCellDelegate.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 3/05/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import UIKit

protocol GenderEntryCellDelegate {
    func textFieldInCell(didSelect cell:GenderEntryCell)
    func textFieldInCell(cell:GenderEntryCell, editingChangedInTextField newText:String)
}
