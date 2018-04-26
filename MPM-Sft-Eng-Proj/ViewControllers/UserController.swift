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
import Photos
import SwiftSpinner

class UserController : UIViewController {
    
    var window: UIWindow?
    
    var selectedImage: UIImage?
    
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
    
    let tapThis: UIButton = {
        let textButton = UIButton()
        let attributeTitle = NSMutableAttributedString(string: "Tap to update",
            attributes: [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10)])
        textButton.setAttributedTitle(attributeTitle, for: .normal)
        textButton.translatesAutoresizingMaskIntoConstraints = false;
        textButton.backgroundColor = UIColor(r: 173, g: 173, b: 173)
        textButton.isHidden = true
        return textButton
    }()

    let profileImageViewHeight: CGFloat = 112
   
    lazy var profileImageView: CachedImageView = {
        var cImg = CachedImageView()
        cImg.translatesAutoresizingMaskIntoConstraints = false
        cImg.contentMode = .scaleAspectFill
        cImg.layer.cornerRadius = profileImageViewHeight / 2
        cImg.clipsToBounds = true
        cImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        cImg.isUserInteractionEnabled = true
        return cImg
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let picker: UIImagePickerController = {
       let p = UIImagePickerController()
       return p
    }()
    
    let bannerView: UIView = {
        let cont = UIView(frame: CGRect.zero)
        cont.backgroundColor = UIColor(r: 173, g: 173, b: 173)
        return cont
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "User Profile"
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.black
        setUpViews()
        loadCurrentUser()
        picker.delegate = self
    }
    
    @objc func handleSelectProfileImageView() {
        print("Photo tapped")
        let photoAuthStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthStatus {
            case .authorized: self.present(self.picker, animated: true, completion: nil)
            case .notDetermined: PHPhotoLibrary.requestAuthorization { (status) in
                if status == PHAuthorizationStatus.authorized {
                    self.present(self.picker, animated: true, completion: nil)
                }
            }
            case .restricted: print("User does not have access to photo album")
            case .denied: print("User denied access")
        }
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
      
        //Setup the banner view
        view.addSubview(bannerView)
        view.addSubview(signOutButton)
        
        bannerView.addSubview(profileImageView)
        bannerView.addSubview(tapThis)
        bannerView.addSubview(nameLabel)
        bannerView.addSubview(emailLabel)
        
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: bannerView.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: profileImageViewHeight).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: profileImageViewHeight).isActive = true
        
        tapThis.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tapThis.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 2).isActive = true
        
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: tapThis.bottomAnchor, constant: 16).isActive = true
        
        emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16).isActive = true
        
        bannerView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: UIScreen.main.bounds.width, heightConstant: 300)
       
        //Temp signout button
        signOutButton.anchor(nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 8, rightConstant: 16, widthConstant: 0, heightConstant: 50)
    }
    
    @objc func loadCurrentUser() {
        if Auth.auth().currentUser != nil {
            SwiftSpinner.show("Loading User Profile...")
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dict = snapshot.value as? [String: Any] else { return }
                let user = User(uid: uid, dictionary: dict)
                //Load user defined profile image if they have set one
                if(user.altProfileImageUrl != Service.defaultProfilePicUrl) {
                    print("loaded alt image")
                    self.profileImageView.loadImage(urlString: user.altProfileImageUrl, completion: {
                        SwiftSpinner.hide()
                        self.nameLabel.text = user.name
                        self.emailLabel.text = user.email
                        self.tapThis.isHidden = false
                    })
                } else {
                    print("loaded preset image")
                    //Load either preset profile image provided by google, or default
                    self.profileImageView.loadImage(urlString: user.profileImageURL, completion: {
                        SwiftSpinner.hide()
                        self.nameLabel.text = user.name
                        self.emailLabel.text = user.email
                        self.tapThis.isHidden = false
                    })
                }
            }, withCancel: { (err) in
                print(err)
            })
        }
    }
}

extension UserController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("finished picking photo")
        //print(info)
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            storeImage(image)
            profileImageView.image = image
            self.dismiss(animated: true, completion: nil)
            SwiftSpinner.show("Updating Profile Picture...")
        }
    }
    
    func storeImage(_ image: UIImage) {
       
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference(forURL: "gs://mpmv1-606b6.appspot.com").child("profileImg").child(userID)
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else { return }
        
        storageRef.putData(imageData, metadata: nil) { (metaData, error) in
            if error != nil {
                return
            }
            print("put data")
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    SwiftSpinner.show("Error Updating Profile Picture...").addTapHandler({
                        SwiftSpinner.hide()
                    })
                    return
                }
                if let downloadUrl = url {
                    let downloadString = downloadUrl.absoluteString
                    Database.database().reference().child("users").child(userID).child("altProfileImageURL").setValue(downloadString)
                    SwiftSpinner.hide()
                }
            })
        }
    }
}

