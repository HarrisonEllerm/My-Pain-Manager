//
//  EnableButtonCell.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Sebastian Peden on 9/20/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

//
//  ButtonCell.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 29/04/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import UIKit

class EnableButtonCell: UITableViewCell {
    
    var name: String?
    var mainImage: UIImage?
    var id: Int?
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: label.font.fontName, size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//    var mainImageView : UIImageView = {
//        var imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 30, height: 30))
//        imageView.contentMode = .scaleAspectFit
//        return imageView
//    }()
    
    var switchButton: UISwitch = {
        let switchButton = UISwitch(frame:CGRect(x: UIScreen.main.bounds.width-60, y: 0, width: 150, height: 300))
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        switchButton.isOn = true
        switchButton.setOn(true, animated: false)
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
        
        //addSubview(mainImageView)
        addSubview(nameLabel)
        addSubview(switchButton)
        
       // nameLabel.leftAnchor.constraint(equalTo: self.mainImageView.rightAnchor, constant: 10).isActive = true
        //nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor,constant: 10).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        switchButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        switchButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        switchButton.addTarget(self, action: #selector(handleAction), for: UIControlEvents.valueChanged)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let message = name {
            nameLabel.text = message
        }
        //if let image = mainImage {
          //  mainImageView.image = image
        //}
    }
    
    @objc func handleAction() {
        guard let idOfCaller = id else { return }
        print("tapped with cell id: \(idOfCaller)")
    }
}
