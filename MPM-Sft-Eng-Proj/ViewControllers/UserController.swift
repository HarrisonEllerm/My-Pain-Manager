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
import Alamofire
import SwiftyBeaver

fileprivate struct SettingsCellData {
    let image: UIImage?
    let message: String?
}

/*
 Connectivity solution adapted from:
 https://stackoverflow.com/questions/30743408/check-for-internet-connection-with-swift
*/
struct Connectivity {
    static let instance = NetworkReachabilityManager()!
    static var connected: Bool {
        return self.instance.isReachable
    }
}

class UserController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var window: UIWindow?
    private var selectedImage: UIImage?
    private let log = SwiftyBeaver.self

    private let settingsTableView: UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.isScrollEnabled = true
        t.tableFooterView = UIView(frame: .zero)
        return t
    }()

    private var data = [SettingsCellData]()

    private let tapThis: UILabel = {
        let label = UILabel()
        label.text = "Tap to Update"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let profileImageViewHeight: CGFloat = 112

    private lazy var profileImageView: CachedImageView = {
        var cImg = CachedImageView()
        cImg.translatesAutoresizingMaskIntoConstraints = false
        cImg.contentMode = .scaleAspectFill
        cImg.layer.cornerRadius = profileImageViewHeight / 2
        cImg.clipsToBounds = true
        cImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        cImg.isUserInteractionEnabled = true
        return cImg
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let picker: UIImagePickerController = {
        let p = UIImagePickerController()
        return p
    }()

    private let bannerView: UIView = {
        let cont = UIView(frame: CGRect.zero)
        return cont
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "User Profile"
        Service.setupNavBar(controller: self)
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

    @objc private func handleSelectProfileImageView() {
        let photoAuthStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthStatus {
        case .authorized: self.present(self.picker, animated: true, completion: nil)
        case .notDetermined: PHPhotoLibrary.requestAuthorization { (status) in
                if status == PHAuthorizationStatus.authorized {
                    self.present(self.picker, animated: true, completion: nil)
                }
            }
        case .restricted: self.log.warning("User does not have access to photo album")
        case .denied: self.log.warning("User denied access")
        }
    }

    @objc private func handleSignOutButtonTapped() {
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { (action) in
            do {
                //Now sign out
                try Auth.auth().signOut()
                let welcomeControl = WelcomeController()
                let welcomeNavCon = UINavigationController(rootViewController: welcomeControl)
                self.tabBarController?.present(welcomeNavCon, animated: true, completion: nil)
            } catch let err {
                self.log.error("Failed to sign out with error \(err)")
                Service.showAlert(on: self, style: .alert, title: "Sign Out Error", message: err.localizedDescription)
                Service.notifyStaffOfError(#file, "\(#function) \(#line): Failed to sign out with error \(err)")
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
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            self.view.backgroundColor = UIColor(patternImage: image)
        } else {
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
            if (Connectivity.connected) {

                guard let uid = Auth.auth().currentUser?.uid else { return }
                let usersRef = Database.database().reference(withPath: "users").child(uid)

                usersRef.observeSingleEvent(of: .value, with: { (snapshot) in

                    guard let dict = snapshot.value as? [String: Any] else { return }
                    let user = User(uid: uid, dictionary: dict)
                    self.pullProfileFromServer(user)
                }, withCancel: { (err) in
                        SwiftSpinner.hide()
                        self.log.error("An error ocurred when loading the current users information: \(err)")
                        Service.notifyStaffOfError(#file, "\(#function) \(#line): An error ocurred when loading the current users information: \(err)")
                    })
            } else {
                /*
                 This only ever occurs if the user successfully logs in,
                 then loses connection before Firebase is able to query and
                 cache their profile info. In this case:
                 
                  -> Display information to the user telling them that
                     they have lost their connection.
                  -> Try to reconnect for 10 seconds. If sucessful, reload
                     profile. If not, dismiss spinner and let user know
                     their profile will be refreshed when they are online.
                 
                 In the case where the above query is successfully executed,
                 and the user goes offline, their profile is persistant.
                */
                warnUserIsOffline()
            }
        }
    }

    fileprivate func warnUserIsOffline() {
        SwiftSpinner.show("You are offline, attempting to reconnect")
        log.warning("User has disconnected from 4G/Wifi")
        //Try to reconnect for 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {

            //If still not connected after 10 seconds
            if !Connectivity.connected {

                SwiftSpinner.show(duration: 3.0, title: "Reconnection Failed, Profile will refresh when connected", animated: false).addTapHandler({
                    SwiftSpinner.hide()
                    self.log.warning("User failed to reconnect after timeout period")
                      Service.notifyStaffOfError(#file, "\(#function) \(#line): User failed to reconnect after timeout period")
                })

            } else if Connectivity.connected {
                //If connection restablishes after 10 seconds
                SwiftSpinner.show(duration: 3.0, title: "Reconnected successfully", animated: false)
                self.log.info("User reconnected succesfully")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.loadCurrentUser()
                }
            }
        }
    }

    /**
        A function that figures out for the current user whether
        or not they have a custom profile picture set. If they do,
        it loads it from the database. If not, it loads the default
        profile image.
     
        - parameter : user, the user object.
    */
    private func pullProfileFromServer(_ user: User) {
        if(user.altProfileImageUrl != Service.defaultProfilePicUrl) {
            self.profileImageView.loadImage(urlString: user.altProfileImageUrl, completion: {
                SwiftSpinner.hide()
                self.nameLabel.text = user.name
                self.emailLabel.text = user.email
                self.tapThis.isHidden = false
            })
        } else {
            self.profileImageView.loadImage(urlString: user.profileImageURL, completion: {
                SwiftSpinner.hide()
                self.nameLabel.text = user.name
                self.emailLabel.text = user.email
                self.tapThis.isHidden = false
            })
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.row == 0) {
            let healthProfileController = HealthProfileController()
            self.navigationController?.pushViewController(healthProfileController, animated: true)
        }else if (indexPath.row == 1){
            let healthProfileController = NotificationsController()
            self.navigationController?.pushViewController(healthProfileController, animated: true)
        }
        else if (indexPath.row == 5) {

        }
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = self.settingsTableView.dequeueReusableCell(withIdentifier: "noButtonCell") as! NoButtonCell
            cell.mainImage = data[indexPath.row].image
            cell.name = data[indexPath.row].message
            cell.id = 0
            cell.accessoryType = .disclosureIndicator
            return cell
        } else if indexPath.row == 1 {
            let cell = self.settingsTableView.dequeueReusableCell(withIdentifier: "noButtonCell") as! NoButtonCell
            cell.mainImage = data[indexPath.row].image
            cell.name = data[indexPath.row].message
            cell.accessoryType = .disclosureIndicator
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

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            storeImage(image)
            profileImageView.image = image
            self.dismiss(animated: true, completion: nil)
            self.log.info("User attempting to update profile picture")
            SwiftSpinner.show("Updating Profile Picture")
        }
    }

    private func storeImage(_ image: UIImage) {
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
            storageRef.downloadURL(completion: { (url, error) in
                if let err = error {
                    self.log.error("Error updating the users profile picture: \(err.localizedDescription)")
                    SwiftSpinner.show("Error Updating Profile Picture...").addTapHandler({
                        Service.notifyStaffOfError(#file, "\(#function) \(#line): Error Updating Profile Picture..")
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

