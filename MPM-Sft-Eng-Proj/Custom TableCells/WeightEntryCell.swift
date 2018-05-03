//
//  WeightEntryCell.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 3/05/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import Foundation
import UIKit

class WeightEntryCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let options = Array(0...150)
    let units = ["Units","kg", "lb"]
    var unitsSet = false
    var textFieldName: String?
    var textFieldValue: String?
    var textFieldUnits: String?
    var delegate: WeightEntryCellDelegate?
    
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: label.font.fontName, size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var valueTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textColor = UIColor.blue
        tf.backgroundColor = UIColor.white
        //gets rid of cursor
        tf.tintColor = UIColor.clear
        tf.clearsOnInsertion = true
        tf.textAlignment = .right
        tf.isHidden = true
        return tf
    }()
    
    var unitsTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textColor = UIColor.blue
        tf.backgroundColor = UIColor.white
        //gets rid of cursor
        tf.tintColor = UIColor.clear
        tf.clearsOnInsertion = true
        tf.textAlignment = .right
        //tf.isHidden = true
        return tf
    }()
    
    let gp = UIPickerView()
    
    let inputAccessoryToolbar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        return toolBar
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        gp.delegate = self
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        inputAccessoryToolbar.setItems([ spaceButton, doneButton], animated: false)
        unitsTextField.inputView = gp
        unitsTextField.inputAccessoryView = inputAccessoryToolbar
        valueTextField.inputView = gp
        valueTextField.inputAccessoryView = inputAccessoryToolbar
        
        gp.selectRow(90, inComponent: 0, animated: true)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(DateEntryCell.didSelectCell))
        addGestureRecognizer(gesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func doneClick() {
        
        self.endEditing(true)
    }
    
    func setupViews() {
        
        addSubview(nameLabel)
        addSubview(valueTextField)
        addSubview(unitsTextField)
        
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        
        unitsTextField.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -28).isActive = true
        unitsTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        unitsTextField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        
        valueTextField.rightAnchor.constraint(equalTo: unitsTextField.leftAnchor, constant: -2).isActive = true
        valueTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        valueTextField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if let message = textFieldName {
            nameLabel.text = message
        }
        if let value = textFieldValue {
            valueTextField.text = value
        }
        if let units = textFieldUnits {
            unitsTextField.text = units
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return options.count
        } else {
            return units.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(options[row])
        } else {
            return String(units[row])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            textFieldValue = String(options[row])
            layoutSubviews()
        } else {
            if(row != 0) {
                valueTextField.isHidden = false
                textFieldUnits = units[row]
                layoutSubviews()
            }
        }
    }
}


extension WeightEntryCell {
    
    @objc func didSelectCell() {
        valueTextField.becomeFirstResponder()
        delegate?.textFieldInCell(didSelect: self)
    }
    @objc func textFieldValueChanged(_ sender: UITextField) {
        if let text = sender.text {
            delegate?.textFieldInCell(cell: self, editingChangedInTextField: text)
        }
    }
}
