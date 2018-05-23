//
//  SignUserUpController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 17/04/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import Foundation

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import SwiftValidator
import SwiftSpinner

class SignUserUpController: UIViewController, UITextFieldDelegate, ValidationDelegate {
    
    //Validator for text fields
    let validator = Validator()
    
    let signUpLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign up below"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 30)
        label.textColor = UIColor.white
        return label
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributeTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 216/255, green: 161/255, blue: 72/255, alpha: 1.0), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)])
        button.setAttributedTitle(attributeTitle, for: .normal)
        attributeTitle.append(NSAttributedString(string: "Sign In" , attributes: [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]))
        button.addTarget(self, action: #selector(signInAction), for: .touchUpInside)
        return button
    }()
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        let attributedPlaceholder = NSAttributedString(string: "name", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        textField.attributedPlaceholder = attributedPlaceholder
        textField.textColor = UIColor.white
        textField.autocapitalizationType = UITextAutocapitalizationType.none
        textField.addIcon(imageName: "name")
        textField.setBottomBorder(backgroundColor: Service.greenTheme, borderColor: .white)
        return textField
    }()
    
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        let attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        textField.attributedPlaceholder = attributedPlaceholder
        textField.textColor = UIColor.white
        textField.autocapitalizationType = UITextAutocapitalizationType.none
        textField.addIcon(imageName: "mail")
        textField.setBottomBorder(backgroundColor: Service.greenTheme, borderColor: .white)
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        let attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        textField.attributedPlaceholder = attributedPlaceholder
        textField.textColor = UIColor.white
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = UITextAutocapitalizationType.none
        textField.addIcon(imageName: "password")
        textField.setBottomBorder(backgroundColor: Service.greenTheme, borderColor: .white)
        return textField
    }()
    
    lazy var registerButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Service.buttonFontSize)
        button.backgroundColor = Service.loginButtonBackgroundColor
        button.layer.cornerRadius = Service.buttonCornerRadius
        button.setTitleColor(UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(handleRegistration), for: .touchUpInside)
        return button
    }()
    
    @objc func handleRegistration() {
        validator.validate(self)
    }
    
    func validationSuccessful() {
        SwiftSpinner.show("Signing up")
        self.view.endEditing(true)
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            SwiftSpinner.show("Sign up error...").addTapHandler({
                SwiftSpinner.hide()
            })
            print("Form is not valid")
            return
        }
        //Authenticate new user
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                SwiftSpinner.show("Sign up error...").addTapHandler({
                    SwiftSpinner.hide()
                })
                print(error)
                return
            }
            //sucessfully authenticated now store in firebase database
            let profilePicUrl = Service.defaultProfilePicUrl
            let altProfilePicUrl = Service.defaultProfilePicUrl
            guard let uid = Auth.auth().currentUser?.uid else {
                SwiftSpinner.show("Sign up error...").addTapHandler({
                    SwiftSpinner.hide()
                })
                return
            }
            let dictionaryValues = ["name": name, "email": email,
                                    "profileImageURL": profilePicUrl, "altProfileImageURL": altProfilePicUrl,
                                    "birthdate": "Not set", "gender": "Not set", "height": "Not set",
                                    "weight": "Not set"]
            let values = [uid: dictionaryValues]
            
            Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, dbRef) in
                if let error = error {
                    SwiftSpinner.show("Sign up error...").addTapHandler({
                        SwiftSpinner.hide()
                    })
                    print(error)
                    return
                }
                //No error, it validated correctly push back to sign in page
                SwiftSpinner.hide()
                self.registerButton.isUserInteractionEnabled = false
                let welcomeController = WelcomeController()
                self.navigationController?.pushViewController(welcomeController, animated: true)
            })
        }
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        for (_, error) in errors {
            if presentedViewController == nil {
                Service.showAlert(on: self, style: .alert, title: "Error", message: error.errorMessage)
            }
        }
    }
    
    @objc func signInAction() {
        let welcomeController = WelcomeController()
        self.view.endEditing(true)
        self.navigationController?.pushViewController(welcomeController, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func viewDidLoad() {
        setUpView()
        setupNavBar()
        //assign the text fields delegate to self, to allow text fields to dissapear
        emailTextField.delegate = self
        passwordTextField.delegate = self
        nameTextField.delegate = self
        
        view.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)
        nameTextField.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)
        emailTextField.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)
        passwordTextField.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)
        registerButton.backgroundColor = UIColor.white
        alreadyHaveAccountButton.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)
        
        
        
        //register text fields that will be validated
        validator.registerField(emailTextField,
                                rules: [RequiredRule(message: "Please provide a email!"),
                                        EmailRule(message: "Please provide a valid email!")])
        validator.registerField(passwordTextField,
                                rules: [RequiredRule(message: "Password Required!"),
                                        MinLengthRule(length: 6, message: "Password must be at least 6 characters long!")])
        validator.registerField(nameTextField, rules: [FullNameRule(message: "Please enter your full name!")])
    }
    
    fileprivate func setupNavBar() {
        navigationController?.navigationBar.isTranslucent = false
        let navigationBarAppearnce = UINavigationBar.appearance()
        navigationBarAppearnce.barTintColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)
        navigationBarAppearnce.tintColor = UIColor(red: 216/255, green: 161/255, blue: 72/255, alpha: 1.0)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController!.navigationBar.topItem!.title = "Back"
    }
    
    
    fileprivate func setUpView() {
        
        view.addSubview(signUpLabel)
        anchorSignupLabel(signUpLabel)
  
        view.addSubview(nameTextField)
        anchorNameTextField(nameTextField)
        
        view.addSubview(emailTextField)
        anchorEmailTextField(emailTextField)
        
        view.addSubview(passwordTextField)
        anchorPasswordTextField(passwordTextField)
        
        view.addSubview(registerButton)
        anchorRegisterButton(registerButton)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 8, rightConstant: 16, widthConstant: 0, heightConstant: 30)
        
    }
    
    fileprivate func anchorSignupLabel(_ label: UILabel) {
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
    }
    
    fileprivate func anchorNameTextField(_ textField: UITextField) {
        textField.anchor(signUpLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 50, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 30)
    }
    
    fileprivate func anchorEmailTextField(_ textField: UITextField) {
        textField.anchor(nameTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 30)
    }
    
    fileprivate func anchorPasswordTextField(_ textField: UITextField) {
        textField.anchor(emailTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 30)
    }
    
    fileprivate func anchorRegisterButton(_ button: UIButton) {
        button.anchor(passwordTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 50)
    }
    
    //Allows text fields to dissapear once they have been delegated
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
