//
//  LoginFlowWorker.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 21/04/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//
import UIKit
import FirebaseAuth

protocol LoginFlowWorker {
    func handleLogin(withWindow window: UIWindow?)
}

extension LoginFlowWorker {
    
    func handleLogin(withWindow window: UIWindow?) {
        
        if let _ = Auth.auth().currentUser {
            //User logged in
            self.showMainApp(withWindow: window)
        } else {
            //No current user, show log in
            self.showLogin(withWindow: window)
        }
    }
    
    func showLogin(withWindow window: UIWindow?) {
        window?.subviews.forEach { $0.removeFromSuperview() }
        window?.rootViewController = nil
        let welcomeController = WelcomeController()
        let welcomeConrollerNav = UINavigationController(rootViewController: welcomeController)
        window?.rootViewController = welcomeConrollerNav
        window?.makeKeyAndVisible()
    }
    
    func showMainApp(withWindow window: UIWindow?) {
        window?.rootViewController = nil
        let mainTabBar = MainTabBarController()
        UIView.transition(with: window!, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                window?.rootViewController = mainTabBar
                window?.makeKeyAndVisible()
        }, completion: nil)
    }
}
