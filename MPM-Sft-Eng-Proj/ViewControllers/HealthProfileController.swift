//
//  HealthProfileController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 1/05/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import UIKit
import FirebaseAuth
import LBTAComponents
import FirebaseDatabase
import FirebaseStorage
import Photos
import SwiftSpinner

class HealthProfileController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "User Profile"
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.black
        setUpViews()
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        data = [SettingsCellData.init(image: #imageLiteral(resourceName: "healthIcon"), message: "Health Profile"), SettingsCellData.init(image: #imageLiteral(resourceName: "notifIcon"), message: "Notifications"),
                SettingsCellData.init(image: #imageLiteral(resourceName: "healthAppIcon"), message: "Integrate Health App"), SettingsCellData.init(image: #imageLiteral(resourceName: "reportIcon"), message: "Weekly Reports"), SettingsCellData.init(image: #imageLiteral(resourceName: "reportIcon"), message: "Monthly Reports"), SettingsCellData.init(image: #imageLiteral(resourceName: "humanIcon"), message: "Model Options")]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    fileprivate func setUpViews() {
        
        view.addSubview(settingsTableView)
        
        settingsTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        settingsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        settingsTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        settingsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        settingsTableView.register(TextEntryCell.self, forCellReuseIdentifier: "textEntryCell")
        settingsTableView.register(GenericHeader.self, forHeaderFooterViewReuseIdentifier: "genericHeader")
        settingsTableView.sectionHeaderHeight = 50
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.settingsTableView.dequeueReusableCell(withIdentifier: "textEntryCell") as! TextEntryCell
        cell.textFieldName = "test"
        cell.textField.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.settingsTableView.dequeueReusableHeaderFooterView(withIdentifier: "genericHeader") as! GenericHeader
        header.textInHeader = "Health Profile"
        return header
    }
    
    //Allows text fields to dissapear once they have been delegated
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
