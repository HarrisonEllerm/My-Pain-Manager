//
//  TextEntryCell.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 1/05/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//
import UIKit
import FirebaseAuth
import FirebaseDatabase

class DateEntryCell: UITableViewCell {
    
    var textFieldName: String?
    var textFieldValue: String?
    var delegate: DateEntryCellDelegate?
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: label.font.fontName, size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textColor = UIColor.blue
        tf.backgroundColor = UIColor.white
        //gets rid of cursor
        tf.tintColor = UIColor.clear
        return tf
    }()
    
    let dp: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        return datePicker
    }()
    
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
        dp.addTarget(self, action: #selector(datePickerChanged(sender:)), for: .valueChanged)
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        inputAccessoryToolbar.setItems([ spaceButton, doneButton], animated: false)
        textField.inputView = dp
        textField.inputAccessoryView = inputAccessoryToolbar
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(DateEntryCell.didSelectCell))
        addGestureRecognizer(gesture)
    }
    
    @objc func datePickerChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        textFieldValue = formatter.string(from: sender.date)
        layoutSubviews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func doneClick() {
        self.endEditing(true)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let inputText = textField.text else { return }
        Database.database().reference().child("users").child(uid).updateChildValues(["birthdate": inputText])
    }
    
    func setupViews() {
        
        addSubview(nameLabel)
        addSubview(textField)
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        
        textField.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -25).isActive = true
        textField.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        textField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        
 
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if let message = textFieldName {
            nameLabel.text = message
        }
        if let value = textFieldValue {
            textField.text = value
        }
    }
    
}

extension DateEntryCell {
    
    @objc func didSelectCell() {
        textField.becomeFirstResponder()
        delegate?.textFieldInCell(didSelect: self)
    }
    @objc func textFieldValueChanged(_ sender: UITextField) {
        if let text = sender.text {
            delegate?.textFieldInCell(cell: self, editingChangedInTextField: text)
        }
    }
}
