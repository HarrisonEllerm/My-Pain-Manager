//
//  ReportController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 17/09/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftSpinner
import SwiftyBeaver
import Alamofire

class ReportController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
    private var startDate: Date?
    private var endDate: Date?
    private let log = SwiftyBeaver.self
    
    private let reportTableView: UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.isScrollEnabled = true
        t.tableFooterView = UIView(frame: .zero)
        t.allowsSelection = true
        t.allowsMultipleSelection = false
        return t
    }()
    
    private lazy var generateButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Generate", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Service.buttonFontSize)
        button.backgroundColor = Service.mainThemeColor
        button.layer.cornerRadius = Service.buttonCornerRadius
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(handleReportGen), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Service.setupNavBar(controller: self)
        view.backgroundColor = UIColor.white
        navigationItem.title = "Generate Report"
        let vc = navigationController?.viewControllers.first
        let button = UIBarButtonItem(title: "Summary", style: .plain, target: self, action: nil)
        vc?.navigationItem.backBarButtonItem = button
        startDate = Date().dateAtStartOf(.year)
        endDate = Date()
        view.addSubview(generateButton)
        setupGenerateButton()
        view.addSubview(reportTableView)
        setUpTable()
    }
    
    @objc private func handleReportGen() {
        log.info("Report Gen Triggered")
        if Auth.auth().currentUser != nil, let uid = Auth.auth().currentUser?.uid,
            let sDate = startDate, let eDate = endDate, let email = Auth.auth().currentUser?.email {
            //Limit users to pull a years worth of data
            if sDate.year != eDate.year {
                Service.showAlert(on: self, style: .alert, title: "Input", message: "Please use a maximum range of one year!")
                return
            } else {
                //Set email intially as the one associated with the users account
                var inputTextField: UITextField?
                
                let alert = UIAlertController(title: "Enter email", message: "Please enter the email address you wish the report to be sent to.", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    self.log.info("User cancelled request for report")
                }))
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                    let entryStr: String = (inputTextField?.text)!.trimmingCharacters(in: .whitespaces)
                    self.log.info("User requested report with email: \(entryStr)")
                    self.finishSendingReport(uid: uid, year: sDate.year, firstMonth: sDate.month, endMonth: eDate.month, email: entryStr)
                }))
                alert.addTextField(configurationHandler: { (textField: UITextField!) in
                    textField.text = email
                    textField.textAlignment = .center
                    inputTextField = textField
                })
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            Service.showAlert(on: self, style: .alert, title: "Whoops!", message: "Something went wrong, make sure both dates are set!")
        }
    }
    
    private func finishSendingReport(uid: String, year: Int, firstMonth: Int, endMonth: Int, email: String) {
        let params = ["uuid": uid,
                      "year": year,
                      "first_Month": firstMonth,
                      "end_Month": endMonth,
                      "email": email] as [String: Any]
        log.info("Sending summary to \(email)")
        log.info("Request details \(params.description)")
        let url = URL(string: "http://mypainmanager.ddns.net:2120/api/mpm/report")
        let headers = ["Content-Type": "application/json"]
        Alamofire.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
        Service.showAlert(on: self, style: .alert, title: "Generating Report", message: "Check your email shortly for your generated report!")
    }
    
    
    private func setUpTable() {
        reportTableView.register(GraphDateEntryCell.self, forCellReuseIdentifier: "graphDateEntry")
        anchorTable()
        reportTableView.delegate = self
        reportTableView.dataSource = self
        reportTableView.rowHeight = 44
        reportTableView.isScrollEnabled = false
        reportTableView.allowsSelection = true
    }
    
    private func setupGenerateButton() {
        generateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        generateButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        generateButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
    }
    
    func anchorTable() {
        reportTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        reportTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        reportTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        reportTableView.bottomAnchor.constraint(equalTo: generateButton.topAnchor).isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateF: DateFormatter = DateFormatter()
        dateF.dateFormat = "dd/MM/yyyy"
        dateF.timeZone = TimeZone(abbreviation: "Pacific/Auckland")
        
        if (indexPath.row == 0) {
            let cell = self.reportTableView.dequeueReusableCell(withIdentifier: "graphDateEntry") as! GraphDateEntryCell
            cell.textFieldName = "From"
            if let start = startDate {
                let startString = dateF.string(from: start)
                cell.textFieldValue = startString
            }
            cell.accessoryType = .disclosureIndicator
            cell.layoutSubviews()
            return cell
        } else {
            let cell = self.reportTableView.dequeueReusableCell(withIdentifier: "graphDateEntry") as! GraphDateEntryCell
            cell.textFieldName = "To"
            if let end = endDate {
                let endString = dateF.string(from: end)
                cell.textFieldValue = endString
            }
            cell.accessoryType = .disclosureIndicator
            cell.layoutSubviews()
            return cell
        }
    }
}
