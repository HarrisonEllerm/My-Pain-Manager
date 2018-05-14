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


class WelcomeController: UIViewController {
    
    var name: String?
    var email: String?
    var profilePicture: UIImage?
    
    
    let loginImg: UIImageView = {
        let img = UIImageView(image: UIImage(named: "MPM_logo"))
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    
    lazy var dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 48/255, alpha: 1)//Service.greenTheme
        let attributeTitle = NSMutableAttributedString(string: "Don't have an account? ",
            attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 216/255, green: 161/255, blue: 72/255, alpha: 1.0),
                         NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)])
        button.setAttributedTitle(attributeTitle, for: .normal)
        attributeTitle.append(NSAttributedString(string: "Sign Up" , attributes:
            [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]))
        button.addTarget(self, action: #selector(signUpAction), for: .touchUpInside)
        return button
    }()
    
    lazy var loginButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Service.buttonFontSize)
        button.layer.cornerRadius = Service.buttonCornerRadius
        button.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        return button
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 48/255, green: 48/255, blue: 43/255, alpha: 1)
      
        loginButton.backgroundColor = UIColor(red: 216/255, green: 161/255, blue: 72/255, alpha: 1.0)
        
        view.addSubview(loginImg)
        anchorLoginImg(loginImg)
        
        view.addSubview(dontHaveAccountButton)
        anchorDontHaveAccountButton(dontHaveAccountButton)
        
        view.addSubview(loginButton)
        anchorLoginButton(loginButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    
    @objc func loginAction() {
        let loginVC = LoginViewConroller()
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    
    @objc func signUpAction() {
        let signUserUpController = SignUserUpController()
        self.navigationController?.pushViewController(signUserUpController, animated: true)
    }
    
    
   
    fileprivate func anchorDontHaveAccountButton(_ button: UIButton) {
        button.anchor(nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 8, rightConstant: 16, widthConstant: 0, heightConstant: 30)
    }
    
    
    
    fileprivate func anchorLoginImg(_ image: UIImageView) {
        image.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 80, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 300)
    }
    
  

    fileprivate func anchorLoginButton(_ button: UIButton) {
        button.anchor(nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: dontHaveAccountButton.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 16, rightConstant: 16, widthConstant: 0, heightConstant: 50)
    }
    
}
