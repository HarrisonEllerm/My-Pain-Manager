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

struct HealthCellData {
    let message : String?
    let value : String?
}


class HealthProfileController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var window: UIWindow?
    var selectedImage: UIImage?
    
    let healthTableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.isScrollEnabled = true
        t.tableFooterView = UIView(frame: .zero)
        return t
    }()
    
    
    lazy var saveButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Service.buttonFontSize)
        button.setTitleColor(Service.buttonTitleColor, for: .normal)
        button.backgroundColor = Service.buttonBackgroundColorSignInAnon
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Service.buttonCornerRadius
//        button.addTarget(self, action: #selector(handleSignOutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    let label = UILabel()
    
    var data = [HealthCellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Health Profile"
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.black
        
        let vc = navigationController?.viewControllers.first
        let button = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: nil)
        vc?.navigationItem.backBarButtonItem = button
        
        setUpViews()
        healthTableView.delegate = self
        healthTableView.dataSource = self
        healthTableView.rowHeight = 44
        healthTableView.isScrollEnabled = false
        data = [HealthCellData.init(message: "Birth Date", value: "Not set"),
                HealthCellData.init(message: "Gender", value: "Not set"),
                HealthCellData.init(message: "Height", value: "Not set"),
                HealthCellData.init(message: "Weight", value: "Not set")]
        
    }
    
    
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    fileprivate func setUpViews() {
        
        view.addSubview(healthTableView)
        view.addSubview(saveButton)
        view.addSubview(label)
        
        healthTableView.register(DateEntryCell.self, forCellReuseIdentifier: "dateEntry")
        healthTableView.register(GenderEntryCell.self, forCellReuseIdentifier: "genderEntry")
        healthTableView.register(HeightEntryCell.self, forCellReuseIdentifier: "heightEntry")
        healthTableView.register(WeightEntryCell.self, forCellReuseIdentifier: "weightEntry")
        healthTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        healthTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        healthTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        healthTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        saveButton.anchor(nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 8, rightConstant: 16, widthConstant: 0, heightConstant: 50)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = self.healthTableView.dequeueReusableCell(withIdentifier: "dateEntry") as! DateEntryCell
            cell.textFieldName = data[indexPath.row].message
            cell.textFieldValue = data[indexPath.row].value
            cell.accessoryType = .disclosureIndicator
            cell.layoutSubviews()
            return cell
        } else if (indexPath.row == 1) {
            let cell = self.healthTableView.dequeueReusableCell(withIdentifier: "genderEntry") as! GenderEntryCell
            cell.textFieldName = data[indexPath.row].message
            cell.textFieldValue = data[indexPath.row].value
            cell.accessoryType = .disclosureIndicator
            cell.layoutSubviews()
            return cell
        } else if (indexPath.row == 2) {
            let cell = self.healthTableView.dequeueReusableCell(withIdentifier: "heightEntry") as! HeightEntryCell
            cell.textFieldName = data[indexPath.row].message
            cell.textFieldUnits = data[indexPath.row].value
            cell.accessoryType = .disclosureIndicator
            cell.layoutSubviews()
            return cell
        } else {
            let cell = self.healthTableView.dequeueReusableCell(withIdentifier: "weightEntry") as! WeightEntryCell
            cell.textFieldName = data[indexPath.row].message
            cell.textFieldUnits = data[indexPath.row].value
            cell.accessoryType = .disclosureIndicator
            cell.layoutSubviews()
            return cell
        }
    }
}


