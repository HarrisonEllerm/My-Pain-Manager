//
//  AlertDialog.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 20/05/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class AlertDialog: UIViewController, UITextViewDelegate {
    
    let alertTitle: UILabel = {
        let label = UILabel()
        label.text = "Log pain rating"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
        label.textColor = UIColor.gray
        return label
    }()
    
    var bodyArea: UILabel = {
        let label = UILabel()
        label.text = "{Body Area}"
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
    
    let starView: CosmosView = {
        let cv = CosmosView()
        cv.settings.starSize = 40
        cv.translatesAutoresizingMaskIntoConstraints = false
        
        return cv
    }()
    
    var painRating: Double?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
    }
    
    fileprivate func setUpView() {
        
        view.addSubview(alertTitle)
        alertTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        alertTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(bodyArea)
        bodyArea.topAnchor.constraint(equalTo: alertTitle.bottomAnchor, constant: 20).isActive = true
        bodyArea.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        starView.rating = 0;
        
        starView.didFinishTouchingCosmos = { rating in
            self.painRating = rating
        }
        
        view.addSubview(starView)
        starView.topAnchor.constraint(equalTo: bodyArea.bottomAnchor, constant: 20).isActive = true
        starView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(textView)
        textView.delegate = self
        textView.heightAnchor.constraint(equalToConstant: 80).isActive = true;
        textView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true;
        textView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true;
        textView.topAnchor.constraint(equalTo: starView.bottomAnchor, constant: 20).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true;
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("text view ended editing - set stuff here")
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func getRating() -> Double {
        guard let realRating = self.painRating else { return 0.0 }
        return realRating
    }
 
}
