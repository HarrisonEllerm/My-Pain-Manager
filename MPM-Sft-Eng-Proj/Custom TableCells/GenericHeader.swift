//
//  GenericHeader.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 29/04/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import UIKit

class GenericHeader: UITableViewHeaderFooterView {
    
    var textInHeader: String?
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0" : nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[v0]-5-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0" : nameLabel]))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let txt = textInHeader {
            nameLabel.text = txt
        }
    }
}
