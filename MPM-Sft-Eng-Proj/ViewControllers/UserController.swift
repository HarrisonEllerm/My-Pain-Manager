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

struct SettingsCellData {
    let image : UIImage?
    let message : String?
}

class UserController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var window: UIWindow?
    var selectedImage: UIImage?
    
    let settingsTableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.isScrollEnabled = true
        t.tableFooterView = UIView(frame: .zero)
        return t
    }()
    
    var data = [SettingsCellData]()
    
    let tapThis: UILabel = {
        let label = UILabel()
        label.text = "Tap to Update"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let picker: UIImagePickerController = {
       let p = UIImagePickerController()
       return p
    }()
    
    let bannerView: UIView = {
        let cont = UIView(frame: CGRect.zero)
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
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        data = [SettingsCellData.init(image: #imageLiteral(resourceName: "healthIcon"), message: "Health Profile"), SettingsCellData.init(image: #imageLiteral(resourceName: "notifIcon"), message: "Notifications"),
                SettingsCellData.init(image: #imageLiteral(resourceName: "healthAppIcon"), message: "Integrate Health App"), SettingsCellData.init(image: #imageLiteral(resourceName: "reportIcon"), message: "Weekly Reports"), SettingsCellData.init(image: #imageLiteral(resourceName: "reportIcon"), message: "Monthly Reports"), SettingsCellData.init(image: #imageLiteral(resourceName: "humanIcon"), message: "Model Options")]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(handleSignOutButtonTapped))
        self.navigationController?.navigationBar.tintColor = UIColor(r: 254, g: 162, b: 25)
        self.settingsTableView.rowHeight = 44.0
    }
    
  
    @objc func handleSelectProfileImageView() {
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
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "userBackground")?.draw(in: self.view.bounds)
        if let image = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            self.view.backgroundColor = UIColor(patternImage: image)
        }else{
            UIGraphicsEndImageContext()
            debugPrint("Image not available")
        }
 
        view.addSubview(settingsTableView)
        bannerView.addSubview(profileImageView)
        bannerView.addSubview(tapThis)
        bannerView.addSubview(nameLabel)
        bannerView.addSubview(emailLabel)

        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: bannerView.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: profileImageViewHeight).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: profileImageViewHeight).isActive = true

        tapThis.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tapThis.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 2).isActive = true

        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: tapThis.bottomAnchor, constant: 16).isActive = true

        emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16).isActive = true

        bannerView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: UIScreen.main.bounds.width, heightConstant: 320)
       
        settingsTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        settingsTableView.topAnchor.constraint(equalTo: bannerView.bottomAnchor).isActive = true
        settingsTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        settingsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        settingsTableView.register(NoButtonCell.self, forCellReuseIdentifier: "noButtonCell")
        settingsTableView.register(GenericHeader.self, forHeaderFooterViewReuseIdentifier: "genericHeader")
        settingsTableView.register(ButtonCell.self, forCellReuseIdentifier: "buttonCell")
        settingsTableView.sectionHeaderHeight = 50
        
    }
    
    @objc func loadCurrentUser() {
        if Auth.auth().currentUser != nil {
            SwiftSpinner.show("Loading User Profile")
            guard let uid = Auth.auth().currentUser?.uid else { return }
           
            let usersRef = Database.database().reference(withPath: "users").child(uid)
            usersRef.keepSynced(true)
            
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0) {
            let healthProfileController = HealthProfileController()
            self.navigationController?.pushViewController(healthProfileController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = self.settingsTableView.dequeueReusableCell(withIdentifier: "noButtonCell") as! NoButtonCell
            cell.mainImage = data[indexPath.row].image
            cell.name = data[indexPath.row].message
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.id = 0
            cell.accessoryType = .disclosureIndicator
            return cell
        } else if indexPath.row == 1 {
            let cell = self.settingsTableView.dequeueReusableCell(withIdentifier: "buttonCell") as! ButtonCell
            cell.mainImage = data[indexPath.row].image
            cell.name = data[indexPath.row].message
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.id = 1
            return cell
        } else if indexPath.row == 2 {
            let cell = self.settingsTableView.dequeueReusableCell(withIdentifier: "buttonCell") as! ButtonCell
            cell.mainImage = data[indexPath.row].image
            cell.name = data[indexPath.row].message
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.id = 2
            return cell
        } else if indexPath.row == 3 {
            let cell = self.settingsTableView.dequeueReusableCell(withIdentifier: "buttonCell") as! ButtonCell
            cell.mainImage = data[indexPath.row].image
            cell.name = data[indexPath.row].message
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.id = 3
            return cell
        } else if indexPath.row == 4 {
            let cell = self.settingsTableView.dequeueReusableCell(withIdentifier: "buttonCell") as! ButtonCell
            cell.mainImage = data[indexPath.row].image
            cell.name = data[indexPath.row].message
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.id = 4
            return cell
        } else {
            let cell = self.settingsTableView.dequeueReusableCell(withIdentifier: "noButtonCell") as! NoButtonCell
            cell.mainImage = data[indexPath.row].image
            cell.name = data[indexPath.row].message
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.id = 5
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.settingsTableView.dequeueReusableHeaderFooterView(withIdentifier: "genericHeader") as! GenericHeader
        header.textInHeader = "Settings"
        return header
    }

}

extension UserController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            storeImage(image)
            profileImageView.image = image
            self.dismiss(animated: true, completion: nil)
            SwiftSpinner.show("Updating Profile Picture")
        }
    }
    
    func storeImage(_ image: UIImage) {
        /*
         Appending current timestamp to end of file name in Firebase Storage
         to prevent situations where overwriting an image with the same name
         would cause the key generated by Firebase for that image to be lost,
         leading to a 403 error if trying to access a new image provided.
        */
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: now)
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference(forURL: "gs://mpmv1-606b6.appspot.com").child("profileImg").child(userID).child(dateString)
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

