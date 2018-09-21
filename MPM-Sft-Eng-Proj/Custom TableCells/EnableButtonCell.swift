//
//  EnableButtonCell.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Sebastian Peden on 9/20/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import UIKit

class EnableButtonCell: UITableViewCell {
    
    var name: String?
    var mainImage: UIImage?
    var id: Int?
    var delegate: EnableButtonCellDelegate?
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: label.font.fontName, size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var switchButton: UISwitch = {
        let switchButton = UISwitch(frame:CGRect(x: UIScreen.main.bounds.width-60, y: 0, width: 150, height: 300))
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        switchButton.isOn = false
        switchButton.onTintColor = UIColor(r: 254, g: 162, b: 25)
        return switchButton
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(nameLabel)
        addSubview(switchButton)
        nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        switchButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        switchButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        switchButton.addTarget(self, action: #selector(notifyDelegate), for: UIControlEvents.valueChanged)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let message = name {
            nameLabel.text = message
        }
    }
    
    @objc private func notifyDelegate() {
        delegate?.buttonActivated(switchButton)
    }
}

protocol EnableButtonCellDelegate {
    func buttonActivated(_ button: UISwitch)
}


