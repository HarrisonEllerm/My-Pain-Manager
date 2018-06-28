//
//  FatigueAlertDialog.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 28/06/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import Foundation
import UIKit

class FatigueAlertDialog: UIViewController, UITextViewDelegate {
    
    let alertTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
        label.textColor = UIColor.gray
        return label
    }()
    
    var rating: UILabel = {
        let label = UILabel()
        label.text = "{rating}"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
        label.textColor = UIColor.gray
        return label
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        tv.layer.cornerRadius = 5
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.borderWidth = 0.5
        tv.textColor = UIColor.gray
        return tv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
    }
    
    fileprivate func setUpView() {
        
        view.addSubview(alertTitle)
        alertTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        alertTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(rating)
        rating.topAnchor.constraint(equalTo: alertTitle.bottomAnchor, constant: 20).isActive = true
        rating.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(textView)
        textView.delegate = self
        textView.heightAnchor.constraint(equalToConstant: 80).isActive = true;
        textView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true;
        textView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true;
        textView.topAnchor.constraint(equalTo: rating.bottomAnchor, constant: 20).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true;
        
    }
    
 
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func getRating() -> Double {
        guard let rating = self.rating.text else { return 0.0 }
        var value = rating
        value.removeLast(6) //Trims " / 100" before conversion
        return Double(value)!
    }
    
    func getDescription() -> String {
        guard let descrip = textView.text else { return "" }
        return descrip;
    }
    
}

