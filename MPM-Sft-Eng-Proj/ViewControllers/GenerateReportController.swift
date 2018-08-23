//
//  GenerateReportController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 24/08/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import NotificationBannerSwift

class GenerateReportController: UIViewController, MFMailComposeViewControllerDelegate {
    
    
    private var generateButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("Generate", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Service.buttonFontSize)
        button.layer.cornerRadius = Service.buttonCornerRadius
        button.addTarget(self, action: #selector(sendSummary), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Service.setupNavBar(controller: self)
        self.navigationItem.title = "Custom Report"
        view.backgroundColor = UIColor.white
        generateButton.backgroundColor = UIColor(red: 216/255, green: 161/255, blue: 72/255, alpha: 1.0)
        setupView()
        
    }
    
    private func setupView() {
        view.addSubview(generateButton)
        anchorGenerateButton(generateButton)
    }
    
    private func anchorGenerateButton(_ button: UIButton) {
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        button.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        button.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
    }
    

    @objc func sendSummary() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["harryellerm@gmail.com"])
            mail.setMessageBody("<p>Testing Testing</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            let emailErrorBanner = NotificationBanner(title: "Could not send report!", subtitle: "Your device may not be configured to send mail...", style: .warning)
            emailErrorBanner.show()
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}
