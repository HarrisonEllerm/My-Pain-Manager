//
//  TextEntryCellDelegate.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 1/05/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import UIKit

protocol TextEntryCellDelegate {
    func textFieldInCell(didSelect cell:TextEntryCell)
    func textFieldInCell(cell:TextEntryCell, editingChangedInTextField newText:String)
}
