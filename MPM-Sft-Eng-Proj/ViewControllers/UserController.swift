//
//  UserController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 17/04/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import UIKit
import FirebaseAuth
import LBTAComponents
import FirebaseDatabase
import FirebaseStorage
import JGProgressHUD

class UserController : UIViewController {
    
    var window: UIWindow?
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    lazy var signOutButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Sign Out", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Service.buttonFontSize)
        button.setTitleColor(Service.buttonTitleColor, for: .normal)
        button.backgroundColor = Service.buttonBackgroundColorSignInAnon
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Service.buttonCornerRadius
        button.addTarget(self, action: #selector(handleSignOutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let profileImageViewHeight: CGFloat = 56
    
    lazy var profileImageView: CachedImageView = {
        var cImg = CachedImageView()
        cImg.backgroundColor = UIColor.white
        cImg.contentMode = .scaleAspectFit
        cImg.layer.cornerRadius = profileImageViewHeight / 2
        cImg.clipsToBounds = true
        return cImg
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    let uidLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "User Profile"
        setUpViews()
    }
    
    @objc func handleSignOutButtonTapped() {
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { (action) in
            do {
                try Auth.auth().signOut()
                let welcomeControl = WelcomeController()
                let welcomeNavCon = UINavigationController(rootViewController: welcomeControl)
                self.tabBarController?.present(welcomeNavCon, animated: true, completion: nil)
            } catch let err {
                print("Failed to sign out with error", err)
                Service.showAlert(on: self, style: .alert, title: "Sign Out Error", message: err.localizedDescription)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        Service.showAlert(on: self, style: .actionSheet, title: nil, message: nil, actions: [signOutAction, cancelAction]) {
        }
    }
    
    fileprivate func setUpViews() {
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(uidLabel)
        view.addSubview(emailLabel)
        view.addSubview(signOutButton)
        view.addSubview(hud)
        
        profileImageView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom:   nil, right: nil, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: profileImageViewHeight, heightConstant: profileImageViewHeight)
        nameLabel.anchor(view.safeAreaLayoutGuide.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 24, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 0)
        uidLabel.anchor(nameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 8, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 0)
        emailLabel.anchor(uidLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 6, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 0)
        signOutButton.anchor(nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 8, rightConstant: 16, widthConstant: 0, heightConstant: 50)
        
        loadCurrentUser()
    }
    
    @objc func loadCurrentUser() {
        if Auth.auth().currentUser != nil {
            hud.textLabel.text = "Loading User Profile..."
            hud.show(in: view, animated: false)
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dict = snapshot.value as? [String: Any] else { return }
                let user = User(uid: uid, dictionary: dict)
                
                self.profileImageView.loadImage(urlString: user.profileImageURL, completion: {
                    self.hud.dismiss()
                    self.nameLabel.text = user.name
                    self.uidLabel.text = user.uid
                    self.emailLabel.text = user.email
                    
                })
            }, withCancel: { (err) in
                print(err)
            })
        }
    }
}

