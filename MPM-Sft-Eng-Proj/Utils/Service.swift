//
//  Service.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 17/04/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import UIKit
import JGProgressHUD
import Alamofire

class Service {
    
    //Colors
    static let baseColor = UIColor(r: 254, g: 202, b: 64)
    static let darkBaseColor = UIColor(r: 253, g: 166, b: 47)
    static let unselectedColor = UIColor(r: 173, g: 173, b: 173)
    static let buttonFontSize: CGFloat = 16
    static let buttonTitleColor = UIColor.white
    static let buttonCornerRadius: CGFloat = 7
    static let loginButtonBackgroundColor = UIColor(displayP3Red: 89 / 255, green: 156 / 255, blue: 120 / 255, alpha: 1)
    static let dontHaveAccountTextColor = UIColor(red: 89/155, green: 156/255, blue: 120/255, alpha: 1)
    static let mainThemeColor = UIColor(red: 216/255, green: 161/255, blue: 72/255, alpha: 1.0)
    
    //Default profile image used if user signs up with email
    static let defaultProfilePicUrl = "https://firebasestorage.googleapis.com/v0/b/mpmv1-606b6.appspot.com/o/user_name_icon.png?alt=media&token=a7186046-6f73-4948-aa12-3154920b4e3c"
    
    //UITabBarInsets
    static let topUITabBarEdgeInset: CGFloat = 4
    static let leftUITabBarEdgeInset: CGFloat = 0
    static let bottomUITabBarEdgeInset: CGFloat = -4
    static let rightUITabBarEdgeInset: CGFloat = 0
    
    //Centralised method used to show alerts to user
    static func showAlert(on: UIViewController, style: UIAlertControllerStyle, title: String?, message: String?, actions: [UIAlertAction] = [UIAlertAction(title: "Ok", style: .default, handler: nil)], completion: (() -> Swift.Void)? = nil)  {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in actions {
            alert.addAction(action)
        }
        on.present(alert, animated: true, completion: completion)
    }
    
    static func setupNavBar(controller: UIViewController) {
        controller.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor:UIColor.white]
        controller.navigationController?.navigationBar.barTintColor = UIColor.black
        controller.view.backgroundColor = UIColor.black
    }
    
    static func notifyStaffOfError(_ clazz: String, _ exception: String) {
        let params = ["class": clazz,
                      "exception_message": exception]
        let url = URL(string: "http://mypainmanager.ddns.net:2118/api/mpm/exception")
        let headers = ["Content-Type": "application/json"]
        Alamofire.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
    }
}

