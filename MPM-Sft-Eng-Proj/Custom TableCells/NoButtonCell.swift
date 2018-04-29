//
//  NoButtonCell.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 29/04/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//
import UIKit

class NoButtonCell: UITableViewCell {
    
    var name: String?
    var mainImage: UIImage?
    var id: Int?
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: label.font.fontName, size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var mainImageView : UIImageView = {
        var imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
//    var switchButton: UISwitch = {
//        let switchButton = UISwitch(frame:CGRect(x: UIScreen.main.bounds.width-60, y: 0, width: 150, height: 300))
//        switchButton.translatesAutoresizingMaskIntoConstraints = false
//        switchButton.isOn = true
//        switchButton.setOn(true, animated: false)
//        switchButton.onTintColor = UIColor(r: 254, g: 162, b: 25)
//        return switchButton
//    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        addSubview(mainImageView)
        addSubview(nameLabel)
  
        nameLabel.leftAnchor.constraint(equalTo: self.mainImageView.rightAnchor, constant: 10).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
   
        //        addSubview(nameLabel)
        //        addSubview(actionButton)
        //        actionButton.addTarget(self, action: #selector(handleAction), for: UIControlEvents.valueChanged)
        //        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0][v1]-16-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0" : nameLabel, "v1": actionButton]))
        //        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[v0]-5-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0" : nameLabel]))
        //        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[v1]-5-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v1" : actionButton]))
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let message = name {
            nameLabel.text = message
        }
        if let image = mainImage {
            mainImageView.image = image
        }
    }
    
    @objc func handleAction() {
        print("tapped")
    }
}
