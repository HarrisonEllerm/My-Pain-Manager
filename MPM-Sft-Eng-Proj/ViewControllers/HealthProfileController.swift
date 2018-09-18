//
//  HealthProfileController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 1/05/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Photos
import SwiftSpinner

fileprivate struct HealthCellData {
    let message : String?
    let value : String?
}

class HealthProfileController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var window: UIWindow?
    // show the view table
    private let healthTableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.isScrollEnabled = true
        t.tableFooterView = UIView(frame: .zero)
        t.allowsSelection = true
        t.allowsMultipleSelection = false
        return t
    }()
    
    let label = UILabel()
    
    private var data = [HealthCellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Service.setupNavBar(controller: self)
        view.backgroundColor = .white
        navigationItem.title = "Health Profile"
        let vc = navigationController?.viewControllers.first
        let button = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: nil)
        vc?.navigationItem.backBarButtonItem = button
        setUpTable()
        setupTableData()
    }
    
    
    /**
     A function to show a table data in the health profile and set the data to database
     */
    private func setupTableData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DispatchQueue.main.async {
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                if let values = snapshot.value as? [String : AnyObject] {
                    let birthdate = values["birthdate"] as! String
                    let gender = values["gender"] as! String
                    let height = values["height"] as! String
                    let weight = values["weight"] as! String
                    
                    self.data = [HealthCellData.init(message: "Birth Date", value: birthdate),
                                 HealthCellData.init(message: "Gender", value: gender),
                                 HealthCellData.init(message: "Height", value: height),
                                 HealthCellData.init(message: "Weight", value: weight)]
                    self.healthTableView.reloadData()
                }
            }
        }
    }
    
    
    fileprivate func setUpTable() {
        view.addSubview(healthTableView)
        view.addSubview(label)
        healthTableView.register(DateEntryCell.self, forCellReuseIdentifier: "dateEntry")
        healthTableView.register(GenderEntryCell.self, forCellReuseIdentifier: "genderEntry")
        healthTableView.register(HeightEntryCell.self, forCellReuseIdentifier: "heightEntry")
        healthTableView.register(WeightEntryCell.self, forCellReuseIdentifier: "weightEntry")
        anchorTable()
        healthTableView.delegate = self
        healthTableView.dataSource = self
        healthTableView.rowHeight = 44
        healthTableView.isScrollEnabled = false
        healthTableView.allowsSelection = true
    }
    
    func anchorTable() {
        healthTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        healthTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        healthTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        healthTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
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


