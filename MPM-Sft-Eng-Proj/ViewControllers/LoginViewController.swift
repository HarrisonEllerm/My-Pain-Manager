//
//  LoginViewController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 12/05/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import Foundation
import UIKit
import SwiftValidator
import FirebaseAuth
import LBTAComponents
import JGProgressHUD
import FirebaseStorage
import FirebaseDatabase
import GoogleSignIn
import SwiftSpinner
import SwiftyBeaver

class LoginViewConroller: UIViewController, UITextFieldDelegate, ValidationDelegate, GIDSignInUIDelegate {
    
    
    private let validator = Validator()
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let log = SwiftyBeaver.self
    
    private let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "Get started below"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 30)
        label.textColor = UIColor.white
        return label
    }()
    
   
    private let emailTextField: UITextField = {
        let textField = UITextField()
        let attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.backgroundColor: UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)])
        textField.attributedPlaceholder = attributedPlaceholder
        textField.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)
        textField.textColor = UIColor.white
        textField.autocapitalizationType = UITextAutocapitalizationType.none
        textField.addIcon(imageName: "mail")
        textField.setBottomBorder(backgroundColor: UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), borderColor: .white)
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        let attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        textField.attributedPlaceholder = attributedPlaceholder
        textField.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)
        textField.textColor = UIColor.white
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = UITextAutocapitalizationType.none
        textField.addIcon(imageName: "password")
        textField.setBottomBorder(backgroundColor: UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), borderColor: .white)
        return textField
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 48/255, alpha: 1)
        let attributeTitle = NSMutableAttributedString(string: "Forgot your password? ",
                                attributes: [NSAttributedStringKey.foregroundColor:
                                    UIColor(red: 216/255, green: 161/255, blue: 72/255, alpha: 1.0),
                                    NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)])
        button.setAttributedTitle(attributeTitle, for: .normal)
        button.addTarget(self, action: #selector(forgotPasswordAction), for: .touchUpInside)
        return button
    }()
    
    private var loginButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitleColor(UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1), for: .normal)
        button.setTitle("Sign In", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Service.buttonFontSize)
        button.layer.cornerRadius = Service.buttonCornerRadius
        button.addTarget(self, action: #selector(handleNormalLogin), for: .touchUpInside)
        return button
        
    }()
    
    private let googleButton: GIDSignInButton = {
        var button = GIDSignInButton()
        return button
    }()
    
    @objc private func forgotPasswordAction() {
        
        var inputTextField: UITextField?
        
        let alert = UIAlertController(title: "Reset password", message: "Please enter the email address associated with your account.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.log.info("User cancelled reset of password")
        }))
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            let entryStr : String = (inputTextField?.text)!.trimmingCharacters(in: .whitespaces)
            self.log.info("User requested email reset with email: \(entryStr)")

            Auth.auth().sendPasswordReset(withEmail: entryStr, completion: { (error) in
                if let err = error {
                    self.log.error("An error ocurred when requesting password reset: \(err.localizedDescription)")
                }
                let notif = UIAlertController(title: "Reset", message: "Please check your email for instructions on how to reset your password", preferredStyle: UIAlertControllerStyle.alert)
                notif.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    self.log.info("User notified about password reset")
                }))
                self.present(notif, animated: true, completion: nil)
            })
        }))
        
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "email"
                inputTextField = textField
        })
    
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func handleNormalLogin() {
        //First validate text fields.
        validator.validate(self)
    }
    
    func validationSuccessful() {
        SwiftSpinner.show("Signing In...")
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.log.error("There was an error signing in: \(error.localizedDescription)")
                SwiftSpinner.show("Failed to sign in...")
                SwiftSpinner.hide()
                return
            }
            SwiftSpinner.hide()
            self.view.endEditing(true)
            self.appDelegate.handleLogin(withWindow: self.appDelegate.window)
        }
    }
    
     func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        for (_, error) in errors {
            if let present = self.presentedViewController {
                present.removeFromParentViewController()
            }
            if presentedViewController == nil {
                Service.showAlert(on: self, style: .alert, title: "Error", message: error.errorMessage)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)
        emailTextField.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)
        passwordTextField.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)
        loginButton.backgroundColor = UIColor.white
        forgotPasswordButton.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)
        setupNavBar()
        setUpViews()
        setUpTextFields()
        //Setup Google Auth
        GIDSignIn.sharedInstance().uiDelegate = self
        //register text fields that will be validated
        validator.registerField(emailTextField, rules: [RequiredRule(message: "Please provide a email!"), EmailRule(message: "Please provide a valid email!")])
        validator.registerField(passwordTextField, rules: [RequiredRule(message: "Password Required!")])
        
         view.accessibilityIdentifier = "loginViewController"
        
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.isTranslucent = false
        let navigationBarAppearnce = UINavigationBar.appearance()
        navigationBarAppearnce.barTintColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)
        navigationBarAppearnce.tintColor = UIColor(red: 216/255, green: 161/255, blue: 72/255, alpha: 1.0)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController!.navigationBar.topItem!.title = "Back"
    }
    
    private func setUpViews() {
        
        view.addSubview(loginLabel)
        anchorLoginLabel(loginLabel)
        
        view.addSubview(emailTextField)
        anchorEmailTextField(emailTextField)
        
        view.addSubview(passwordTextField)
        anchorPasswordTextField(passwordTextField)
        
        view.addSubview(loginButton)
        anchorLoginButton(loginButton)
        
        view.addSubview(googleButton)
        anchorGoogleButton(googleButton)
        
        view.addSubview(forgotPasswordButton)
        anchorForgotPasswordButton(forgotPasswordButton)
        
    }
    
    private func anchorLoginLabel(_ label: UILabel) {
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
    }
    
    private func anchorEmailTextField(_ textField: UITextField) {
        textField.anchor(loginLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 50, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 30)
    }
    
    private func anchorPasswordTextField(_ textField: UITextField) {
        textField.anchor(emailTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 30)
    }
    
    private func anchorLoginButton(_ button: UIButton) {
        button.anchor(passwordTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 50)
    }
    
    private func anchorGoogleButton(_ button: GIDSignInButton) {
        button.anchor(loginButton.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor,
                          bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 16,
                          leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0,
                          heightConstant: 50)
    }
    
    private func anchorForgotPasswordButton(_ button: UIButton) {
        button.anchor(nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 8, rightConstant: 16, widthConstant: 0, heightConstant: 30)
    }
    
    private func setUpTextFields() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    //Allows text fields to dissapear once they have been delegated
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
