//
//  Service.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 17/04/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import UIKit
import LBTAComponents
import JGProgressHUD

class Service {
    
    //Colors
    static let baseColor = UIColor(r: 254, g: 202, b: 64)
    static let darkBaseColor = UIColor(r: 253, g: 166, b: 47)
    static let unselectedColor = UIColor(r: 173, g: 173, b: 173)
    static let buttonFontSize: CGFloat = 16
    static let buttonTitleColor = UIColor.white
    static let buttonCornerRadius: CGFloat = 7
    static let buttonBackgroundColorSignInAnon = UIColor(r: 54, g: 54, b: 54)
    static let buttonBackgroundColorSignInFB = UIColor(r: 128, g: 128, b: 255)
    static let loginButtonBackgroundColor = UIColor(displayP3Red: 89 / 255, green: 156 / 255, blue: 120 / 255, alpha: 1)
    static let greenTheme = UIColor(displayP3Red: 109/255, green: 201/255, blue: 149/255, alpha: 1 )
    static let dontHaveAccountTextColor = UIColor(red: 89/155, green: 156/255, blue: 120/255, alpha: 1)
    
    //Default profile image used if user signs up with email
    static let defaultProfilePicUrl = "https://firebasestorage.googleapis.com/v0/b/mypainmanager.appspot.com/o/profileImages%2Ficons8-female-profile-50%20(1).png?alt=media&token=dbe2838b-1de2-4c35-8f7d-bfd3c7edf00e"
    
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
    
    //Convienience method used to dismuss a HUD
    static func dismissHud(_ hud: JGProgressHUD, text: String, detailText: String, delay: TimeInterval) {
        hud.textLabel.text = text
        hud.detailTextLabel.text = detailText
        hud.dismiss(afterDelay: delay, animated: true)
    }
}

