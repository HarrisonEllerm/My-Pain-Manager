//
//  NotificationsController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Sebastian Peden on 9/18/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.

import UIKit
import FirebaseAuth
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Photos
import SwiftSpinner

fileprivate struct NotificationCellData {
    let message : String?
    let value : String?
}

class NotificationsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var window: UIWindow?
    // show the view table
    private let NotificationTableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.isScrollEnabled = true
        t.tableFooterView = UIView(frame: .zero)
        t.allowsSelection = true
        t.allowsMultipleSelection = false
        return t
    }()
    
    let label = UILabel()
    
    private var data = [NotificationCellData]()
    
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
        
        
        self.data = [NotificationCellData.init(message: "Period", value: "Daily"),
                     NotificationCellData.init(message: "Time", value: "12:00"),
                     NotificationCellData.init(message: "EnableNotificaitons", value: "True")]
        
    }
    
    
    fileprivate func setUpTable() {
        view.addSubview(NotificationTableView)
        view.addSubview(label)
        NotificationTableView.register(PeriodEntryCell.self, forCellReuseIdentifier: "periodEntry")
        NotificationTableView.register(TimeEntryCell.self, forCellReuseIdentifier: "timeEntry")
        NotificationTableView.register(ButtonCell.self, forCellReuseIdentifier: "buttonCell")
        anchorTable()
        NotificationTableView.delegate = self
        NotificationTableView.dataSource = self
        NotificationTableView.rowHeight = 44
        NotificationTableView.isScrollEnabled = false
        NotificationTableView.allowsSelection = true
    }
    
    func anchorTable() {
        NotificationTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        NotificationTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        NotificationTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        NotificationTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = self.NotificationTableView.dequeueReusableCell(withIdentifier: "periodEntry") as! PeriodEntryCell
            cell.textFieldName = data[indexPath.row].message
            cell.textFieldValue = data[indexPath.row].value
            cell.accessoryType = .disclosureIndicator
            cell.layoutSubviews()
            return cell
        } else if (indexPath.row == 1) {
            let cell = self.NotificationTableView.dequeueReusableCell(withIdentifier: "timeEntry") as! TimeEntryCell
            cell.textFieldName = data[indexPath.row].message
            cell.textFieldValue = data[indexPath.row].value
            cell.accessoryType = .disclosureIndicator
            cell.layoutSubviews()
            return cell
        } else {
            let cell = self.NotificationTableView.dequeueReusableCell(withIdentifier: "buttonCell") as! ButtonCell
            cell.name = "Enabled"
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }
}
