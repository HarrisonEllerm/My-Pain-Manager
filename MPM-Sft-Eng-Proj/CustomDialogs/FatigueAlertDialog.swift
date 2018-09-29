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

    var noteSet: Bool = false
    var medNoteSet: Bool = false

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

    let logMedicationSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Notes", "Medication"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.tintColor = Service.mainThemeColor
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(FatigueAlertDialog.changeVC), for: .valueChanged)
        return control
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

    let notesTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        tv.layer.cornerRadius = 5
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.borderWidth = 0.5
        tv.textColor = UIColor.lightGray
        tv.text = "Extra notes regarding fatigue..."
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
        tv.text = "Notes about medication types and dosages used to manage fatigue..."
        tv.textAlignment = .center
        return tv
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()

    }

    fileprivate func setUpView() {

        //Setup Title
        view.addSubview(alertTitle)
        setupAlertTitle()

        //Setup rating
        view.addSubview(rating)
        setupRating()

        //Setup Segmented Control
        view.addSubview(logMedicationSegmentedControl)
        setupSegmentedControl()

        //Setup the Container view for use with Segmented Control
        //with its two subviews
        viewContainer.addSubview(medsInputContainerView)
        viewContainer.addSubview(notesInputContainerView)
        view.addSubview(viewContainer)
        setupViewContainer()
        setupNotesInputsContainerView()
        setupMedsInputsContainerView()

        //Setup the Notes Text View
        notesInputContainerView.addSubview(notesTextView)
        notesTextView.delegate = self
        setupNotesTextView()

        //Setup the Meds Text View
        medsInputContainerView.addSubview(medsTextView)
        medsTextView.delegate = self
        setUpMedsTextView()

    }

    fileprivate func setUpMedsTextView() {
        medsTextView.topAnchor.constraint(equalTo: medsInputContainerView.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        medsTextView.leftAnchor.constraint(equalTo: medsInputContainerView.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        medsTextView.rightAnchor.constraint(equalTo: medsInputContainerView.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        medsTextView.bottomAnchor.constraint(equalTo: medsInputContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
    }

    fileprivate func setupNotesTextView() {
        notesTextView.delegate = self
        notesTextView.topAnchor.constraint(equalTo: viewContainer.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        notesTextView.leftAnchor.constraint(equalTo: viewContainer.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        notesTextView.rightAnchor.constraint(equalTo: viewContainer.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        notesTextView.bottomAnchor.constraint(equalTo: viewContainer.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
    }

    fileprivate func setupMedsInputsContainerView() {
        medsInputContainerView.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor).isActive = true
        medsInputContainerView.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor).isActive = true
        medsInputContainerView.widthAnchor.constraint(equalTo: viewContainer.safeAreaLayoutGuide.widthAnchor).isActive = true
        medsInputContainerView.heightAnchor.constraint(equalTo: viewContainer.heightAnchor).isActive = true
    }

    fileprivate func setupNotesInputsContainerView() {
        notesInputContainerView.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor).isActive = true
        notesInputContainerView.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor).isActive = true
        notesInputContainerView.widthAnchor.constraint(equalTo: viewContainer.safeAreaLayoutGuide.widthAnchor).isActive = true
        notesInputContainerView.heightAnchor.constraint(equalTo: viewContainer.heightAnchor).isActive = true
    }

    fileprivate func setupViewContainer() {
        viewContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        viewContainer.topAnchor.constraint(equalTo: logMedicationSegmentedControl.bottomAnchor, constant: 10).isActive = true
        viewContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        viewContainer.heightAnchor.constraint(equalToConstant: 80).isActive = true
        viewContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    fileprivate func setupSegmentedControl() {
        logMedicationSegmentedControl.topAnchor.constraint(equalTo: rating.safeAreaLayoutGuide.bottomAnchor, constant: 20).isActive = true
        logMedicationSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    fileprivate func setupAlertTitle() {
        alertTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        alertTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    fileprivate func setupRating() {
        rating.topAnchor.constraint(equalTo: alertTitle.bottomAnchor, constant: 20).isActive = true
        rating.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
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

}

