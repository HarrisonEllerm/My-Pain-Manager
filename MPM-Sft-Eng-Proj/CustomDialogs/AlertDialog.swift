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
    
    var painRating: Double?
    var noteSet: Bool = false
    var medNoteSet: Bool = false
    
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
    
    let notesTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        tv.layer.cornerRadius = 5
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.borderWidth = 0.5
        tv.textColor = UIColor.lightGray
        tv.text = "Extra notes regarding pain..."
        tv.textAlignment = .center
        return tv
    }()
    
    let medsTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        tv.layer.cornerRadius = 5
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.borderWidth = 0.5
        tv.textColor = UIColor.lightGray
        tv.text = "Notes about medication types and dosages used to manage pain..."
        tv.textAlignment = .center
        return tv
    }()
    
    let viewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let notesInputContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let medsInputContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let starView: CosmosView = {
        let cv = CosmosView()
        cv.settings.starSize = 40
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    

    let logMedicationSegmentedControl : UISegmentedControl = {
        let control = UISegmentedControl(items: ["Notes", "Medication"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.tintColor = Service.mainThemeColor
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(AlertDialog.changeVC), for: .valueChanged)
        return control
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
    }
    
    fileprivate func setUpView() {
        //Setup Title
        view.addSubview(alertTitle)
        setUpTitle()
        
        //Setup Body Area
        view.addSubview(bodyArea)
        setUpBodyArea()
        
        //Setup Stars for rating
        view.addSubview(starView)
        setUpStarView()
        
        //Setup Segmented Control
        view.addSubview(logMedicationSegmentedControl)
        setUpSegmentedControl()
        
        //Setup the Container view for use with Segmented Control
        //with its two subviews
        viewContainer.addSubview(medsInputContainerView)
        viewContainer.addSubview(notesInputContainerView)
        view.addSubview(viewContainer)
        setUpViewContainer()
        setUpNotesInputsContainerView()
        setUpMedsInputsContainerView()
        
        //Setup the Notes Text View
        notesInputContainerView.addSubview(notesTextView)
        notesTextView.delegate = self
        setUpNotesTextView()
        
        //Setup the Meds Text View
        medsInputContainerView.addSubview(medsTextView)
        medsTextView.delegate = self
        setUpMedsTextView()
    
    }
    
    fileprivate func setUpViewContainer() {
        viewContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        viewContainer.topAnchor.constraint(equalTo: logMedicationSegmentedControl.bottomAnchor, constant: 10).isActive = true
        viewContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        viewContainer.heightAnchor.constraint(equalToConstant: 80).isActive = true
        viewContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    fileprivate func setUpMedsTextView() {
        medsTextView.topAnchor.constraint(equalTo: medsInputContainerView.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        medsTextView.leftAnchor.constraint(equalTo: medsInputContainerView.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        medsTextView.rightAnchor.constraint(equalTo: medsInputContainerView.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        medsTextView.bottomAnchor.constraint(equalTo: medsInputContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
    }
    
    fileprivate func setUpMedsInputsContainerView() {
        medsInputContainerView.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor).isActive = true
        medsInputContainerView.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor).isActive = true
        medsInputContainerView.widthAnchor.constraint(equalTo: viewContainer.safeAreaLayoutGuide.widthAnchor).isActive = true
        medsInputContainerView.heightAnchor.constraint(equalTo: viewContainer.heightAnchor).isActive = true
    }
    
    fileprivate func setUpSegmentedControl() {
        logMedicationSegmentedControl.topAnchor.constraint(equalTo: starView.safeAreaLayoutGuide.bottomAnchor, constant: 20).isActive = true
        logMedicationSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    fileprivate func setUpNotesTextView() {
        notesTextView.delegate = self
        notesTextView.topAnchor.constraint(equalTo: viewContainer.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        notesTextView.leftAnchor.constraint(equalTo: viewContainer.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        notesTextView.rightAnchor.constraint(equalTo: viewContainer.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        notesTextView.bottomAnchor.constraint(equalTo: viewContainer.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
    }
    
    fileprivate func setUpTitle() {
        alertTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        alertTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    fileprivate func setUpBodyArea() {
        bodyArea.topAnchor.constraint(equalTo: alertTitle.bottomAnchor, constant: 20).isActive = true
        bodyArea.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    fileprivate func setUpStarView() {
        starView.rating = 0;
        starView.didFinishTouchingCosmos = { rating in
            self.painRating = rating
        }
        starView.topAnchor.constraint(equalTo: bodyArea.bottomAnchor, constant: 20).isActive = true
        starView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    fileprivate func setUpNotesInputsContainerView() {
        notesInputContainerView.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor).isActive = true
        notesInputContainerView.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor).isActive = true
        notesInputContainerView.widthAnchor.constraint(equalTo: viewContainer.safeAreaLayoutGuide.widthAnchor).isActive = true
        notesInputContainerView.heightAnchor.constraint(equalTo: viewContainer.heightAnchor).isActive = true
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
    
    func getNotesDescription() -> (String, Bool) {
        guard let descrip = notesTextView.text else { return ("", false) }
        let result = (descrip, noteSet)
        return result
    }
    
    func getMedsDescription() -> (String, Bool) {
        guard let descrip = medsTextView.text else { return ("", false) }
        let result = (descrip, medNoteSet)
        return result
    }
    
    @objc func changeVC(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            viewContainer.bringSubview(toFront: notesInputContainerView)
        case 1:
            viewContainer.bringSubview(toFront: medsInputContainerView)
        default:
            viewContainer.bringSubview(toFront: notesInputContainerView)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == notesTextView {
            noteSet = true
        } else {
            medNoteSet = true
        }
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.gray
        }
    }
}
