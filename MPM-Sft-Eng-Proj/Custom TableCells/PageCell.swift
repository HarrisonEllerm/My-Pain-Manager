//
//  PageCell.swift
//  TestOnboarding
//
//  Created by Harrison Ellerm on 23/05/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import UIKit


protocol PageCellDelegate: class {
    func letsGoPressed(cell: UICollectionViewCell)
}

class PageCell: UICollectionViewCell, LoginFlowWorker {
    
    var delegate: PageCellDelegate?
    
    var page: Page? {
        didSet {
            guard let page = page else { return }
            imageView.image = page.image
            let color = UIColor(white: 1, alpha: 1)
            let attributedText = NSMutableAttributedString(string: page.title, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 22, weight: .medium), NSAttributedStringKey.foregroundColor : color])
            attributedText.append(NSAttributedString(string: "\n\n\(page.message)", attributes: [NSAttributedStringKey.font :
                UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor : color]))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            attributedText.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle,
                                        range: NSRange(location: 0, length: attributedText.string.count))
            textView.attributedText = attributedText
            if page.showButton {
                getStarted.isHidden = false
                getStarted.isEnabled = true
                
            }
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.contentInset = UIEdgeInsetsMake(24, 0, 0, 0)
        tv.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)
   
        return tv
    }()
    
    lazy var getStarted: UIButton = {
        var button = UIButton(type: .system)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("Let's go", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Service.buttonFontSize)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.isEnabled = false
        button.setTitleColor(UIColor(red: 216/255, green: 161/255, blue: 72/255, alpha: 1.0), for: .normal)
        button.addTarget(self, action: #selector(dismissOnBoard), for: .touchUpInside)
        return button
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @objc func dismissOnBoard() {
       delegate?.letsGoPressed(cell: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)
        addSubview(imageView)
        addSubview(containerView)
        //Add to container view
        containerView.addSubview(textView)
        containerView.addSubview(getStarted)
        //Anchor container view
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        containerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        //Add to container view
        getStarted.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -80).isActive = true
        getStarted.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true

        textView.bottomAnchor.constraint(equalTo: getStarted.topAnchor, constant: -10).isActive = true
        textView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
        textView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
        textView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 90).isActive = true
        
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 100).isActive = true
        imageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -100).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 60).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -60).isActive = true
        

    }
    

}
