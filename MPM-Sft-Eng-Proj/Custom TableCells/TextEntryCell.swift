//
//  TextEntryCell.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 1/05/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//
import UIKit

class TextEntryCell: UITableViewCell {
    
    var textFieldName: String?
    var id: Int?
    var delegate: TextEntryCellDelegate?
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: label.font.fontName, size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textColor = UIColor.black
        return tf
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(TextEntryCell.didSelectCell))
        addGestureRecognizer(gesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        /*
         
         nameLabel.leftAnchor.constraint(equalTo: self.mainImageView.rightAnchor, constant: 10).isActive = true
         nameLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
         nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
         nameLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
         
         switchButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
         switchButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
         switchButton.addTarget(self, action: #selector(handleAction), for: UIControlEvents.valueChanged)
 
 
 
        */
        
        addSubview(nameLabel)
        addSubview(textField)
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        
        textField.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 20).isActive = true
        textField.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        textField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        
 
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let message = textFieldName {
            nameLabel.text = message
        }
    }
    
}

extension TextEntryCell {
    
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
