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
        let img = UIImageView(image: UIImage(named: "loginText"))
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        let attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        textField.attributedPlaceholder = attributedPlaceholder
        textField.backgroundColor = Service.greenTheme
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
        textField.backgroundColor = Service.greenTheme
        textField.textColor = UIColor.white
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = UITextAutocapitalizationType.none
        textField.addIcon(imageName: "password")
        textField.setBottomBorder(backgroundColor: Service.greenTheme, borderColor: .white)
        return textField
    }()
    
    
    var loginButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Service.buttonFontSize)
        button.backgroundColor = Service.loginButtonBackgroundColor
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
        button.backgroundColor = Service.greenTheme
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
        view.backgroundColor = Service.greenTheme
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
        hud.detailTextLabel.text = "";
        hud.textLabel.text = "Signing In..."
        hud.show(in: view, animated: true)
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("Error signing in: \(error)")
                Service.dismissHud(self.hud, text: "Error", detailText: error.localizedDescription, delay: 3)
                return
            }
            /*
             Normal sign in ok, allow slight delay to dismiss hud, then push new page.
             */
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.appDelegate.handleLogin(withWindow: self.appDelegate.window)
            }
        }
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        for (_, error) in errors {
            Service.showAlert(on: self, style: .alert, title: "Error", message: error.errorMessage)
        }
    }
    
    @objc func signUpAction() {
        let signUserUpController = SignUserUpController()
        self.present(signUserUpController, animated: true, completion: nil)
    }
    
    fileprivate func setUpViews() {
        
        view.addSubview(loginImg)
        anchorLoginImg(loginImg)
        
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
        image.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 180, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 50)
    }
    
    fileprivate func anchorEmailTextField(_ textField: UITextField) {
        textField.anchor(loginImg.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 50, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 30)
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
    
    //Sets status bar style to allow white text
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //Allows text fields to dissapear once they have been delegated
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
