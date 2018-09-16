//
//  ReportController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 17/09/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Photos
import SwiftSpinner
import AUPickerCell

class ReportController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let reportTableView: UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.isScrollEnabled = true
        t.tableFooterView = UIView(frame: .zero)
        t.allowsSelection = true
        t.allowsMultipleSelection = false
        return t
    }()

    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
        "Aug", "Sep", "Oct", "Nov", "Dec"]

    override func viewDidLoad() {
        super.viewDidLoad()
        Service.setupNavBar(controller: self)
        view.backgroundColor = .white
        navigationItem.title = "Generate Report"
        let vc = navigationController?.viewControllers.first
        let button = UIBarButtonItem(title: "Summary", style: .plain, target: self, action: nil)
        vc?.navigationItem.backBarButtonItem = button
        setUpTable()
    }

    fileprivate func setUpTable() {
        view.addSubview(reportTableView)
        anchorTable()
        reportTableView.delegate = self
        reportTableView.dataSource = self
        reportTableView.rowHeight = 44
        reportTableView.isScrollEnabled = false
        reportTableView.allowsSelection = true
    }

    func anchorTable() {
        reportTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        reportTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        reportTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        reportTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = AUPickerCell(type: .default, reuseIdentifier: "TableCell")
            cell.values = months
            cell.selectedRow = 1
            cell.leftLabel.text = "Start Month"
            return cell
        } else if indexPath.row == 1 {
            let cell = AUPickerCell(type: .default, reuseIdentifier: "TableCell")
            cell.values = months
            cell.selectedRow = 1
            cell.leftLabel.text = "End Month"
            return cell
        } else {
            let cell = AUPickerCell(type: .default, reuseIdentifier: "TableCell")
            cell.values = ["2018"]
            cell.selectedRow = 1
            cell.leftLabel.text = "Year"
            return cell
        }
    }
}



