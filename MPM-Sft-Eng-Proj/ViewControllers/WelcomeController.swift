//
//  WelcomeController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 17/04/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import Foundation

import UIKit
import FirebaseAuth
import LBTAComponents
import JGProgressHUD
import SwiftyJSON
import FirebaseStorage
import FirebaseDatabase
import SwiftValidator
import GoogleSignIn
import SwiftSpinner


class WelcomeController: UIViewController, UITextFieldDelegate, ValidationDelegate, GIDSignInUIDelegate {
    
    var name: String?
    var email: String?
    var profilePicture: UIImage?
    var signInCount: Int = 0
    //Validator for text fields
    let validator = Validator()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    let loginImg: UIImageView = {
        let img = UIImageView(image: UIImage(named: "MPM_logo2"))
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    
    let logoText: UIImageView = {
        let img = UIImageView(image: UIImage(named: "words"))
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        let attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        textField.attributedPlaceholder = attributedPlaceholder
        textField.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1) //Service.greenTheme
        textField.textColor = UIColor.white
        textField.autocapitalizationType = UITextAutocapitalizationType.none
        textField.addIcon(imageName: "mail")
        textField.setBottomBorder(backgroundColor: UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), borderColor: .white)
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        let attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        textField.attributedPlaceholder = attributedPlaceholder
        textField.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1) //Service.greenTheme
        textField.textColor = UIColor.white
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = UITextAutocapitalizationType.none
        textField.addIcon(imageName: "password")
        textField.setBottomBorder(backgroundColor: UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), borderColor: .white)
        return textField
    }()
    
    
    var loginButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Service.buttonFontSize)
        button.backgroundColor = UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1)//Service.loginButtonBackgroundColor
        button.layer.cornerRadius = Service.buttonCornerRadius
        button.addTarget(self, action: #selector(handleNormalLogin), for: .touchUpInside)
        return button
        
    }()
    
    
    let googleButton: GIDSignInButton = {
        var button = GIDSignInButton()
        return button
    }()
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 48/255, alpha: 1)//Service.greenTheme
        let attributeTitle = NSMutableAttributedString(string: "Don't have an account? ",
            attributes: [NSAttributedStringKey.foregroundColor: Service.dontHaveAccountTextColor,
                         NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)])
        button.setAttributedTitle(attributeTitle, for: .normal)
        attributeTitle.append(NSAttributedString(string: "Sign Up" , attributes:
            [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]))
        button.addTarget(self, action: #selector(signUpAction), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1) // Service.greenTheme
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setUpViews()
        //assign the text fields delegate to self, to allow text fields to dissapear
        emailTextField.delegate = self
        passwordTextField.delegate = self
        //Setup Google Auth
        GIDSignIn.sharedInstance().uiDelegate = self
        //register text fields that will be validated
        validator.registerField(emailTextField, rules: [RequiredRule(message: "Please provide a email!"), EmailRule(message: "Please provide a valid email!")])
        validator.registerField(passwordTextField, rules: [RequiredRule(message: "Password Required!")])
    }
    
    
    
    @objc func handleNormalLogin() {
        //First validate text fields.
        validator.validate(self)
    }
    
    
    func validationSuccessful() {
        SwiftSpinner.show("Signing In...")
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("Error signing in: \(error)")
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
    
    @objc func signUpAction() {
        let signUserUpController = SignUserUpController()
        self.present(signUserUpController, animated: true, completion: nil)
    }
    
    fileprivate func setUpViews() {
        
        view.addSubview(loginImg)
        anchorLoginImg(loginImg)
        
        view.addSubview(logoText)
        anchorLogoText(logoText)
        
        view.addSubview(emailTextField)
        anchorEmailTextField(emailTextField)
        
        view.addSubview(passwordTextField)
        anchorPasswordTextField(passwordTextField)
        
        view.addSubview(loginButton)
        anchorLoginButton(loginButton)
        
        view.addSubview(googleButton)
        anchorGoogleButton(googleButton)
        
        view.addSubview(dontHaveAccountButton)
        anchorDontHaveAccountButton(dontHaveAccountButton)
        
    }
    
    fileprivate func anchorLoginImg(_ image: UIImageView) {
        image.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 60, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 250)
    }
    
    fileprivate func anchorLogoText(_ image: UIImageView) {
        image.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 260, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 100)
    }
    
    
    fileprivate func anchorEmailTextField(_ textField: UITextField) {
        textField.anchor(loginImg.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 100, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 30)
    }
    
    fileprivate func anchorPasswordTextField(_ textField: UITextField) {
        textField.anchor(emailTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 30)
    }
    
    fileprivate func anchorLoginButton(_ button: UIButton) {
        button.anchor(passwordTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 50)
    }
    
    fileprivate func anchorGoogleButton(_ button: GIDSignInButton) {
        button.anchor(loginButton.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor,
                      bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 16,
                      leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0,
                      heightConstant: 50)
    }
    
    fileprivate func anchorDontHaveAccountButton(_ button: UIButton) {
        button.anchor(nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 8, rightConstant: 16, widthConstant: 0, heightConstant: 30)
    }
        
    //Allows text fields to dissapear once they have been delegated
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
