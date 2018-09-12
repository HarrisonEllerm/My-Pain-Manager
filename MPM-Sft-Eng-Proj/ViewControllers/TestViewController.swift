//
//  TestViewController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 12/09/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class TestViewController: UIViewController {
    
    var dataSnapShots = [DataSnapshot]()
    var months = ["Aug", "Sep"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let button = UIButton(frame: CGRect(x: self.view.frame.size.width / 2 - 50, y: self.view.frame.size.height / 2 - 25, width: 100, height: 50))
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("Push Me", for: .normal)
        button.addTarget(self, action: #selector(queryBasedOnDateRange), for: .touchUpInside)
        button.backgroundColor = UIColor.black
        button.titleLabel?.textColor = UIColor.black
        self.view.addSubview(button)
    }
    
    @objc func pushDataToFirebase() {
        let painDictionary = ["date_string": "15/08/2018", "medsNotes": "N/A", "month_short_name": "Aug", "notes": "N/A", "ranking": "5", "time_string": "12:00:00", "type": "Stomach"]
        //Push to firebase generating auto unique id
        Database.database().reference()
            .child("pain_log_test")
            .child("G0LZ3XNH6JYf9zRtl7ocIvsD3ZD2")
            .childByAutoId()
            .updateChildValues(painDictionary)
    }
    
   
    @objc func queryBasedOnDateRange() {
        print("Query Called")
        let ref = Database.database().reference(withPath: "pain_log_test").child("G0LZ3XNH6JYf9zRtl7ocIvsD3ZD2")
        ref.queryOrdered(byChild: "month_short_name").queryStarting(atValue: 4)
            .queryEnding(atValue: 12)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshots {
                       print(snap)
                    }
                } else {
                    print("Snapshots empty")
                }
            }) { (error) in
                print("Error")
        }
    
    }

}
