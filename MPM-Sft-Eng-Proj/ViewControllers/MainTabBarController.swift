//
//  MainTabBarController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 17/04/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import FirebaseAuth
import UIKit

class MainTabBarController: UITabBarController {
    
    let homeController: HomeController = HomeController()
    let userController: UserController = UserController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLoggedInUserStatus()
        setUpViewControllers()
        
    }
    
    //Checks if user is logged in, if not redirects to sign in page.
    func checkLoggedInUserStatus() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let welcomeController = WelcomeController()
                let signUpNavigationController = UINavigationController(rootViewController: welcomeController)
                self.present(signUpNavigationController, animated: false, completion: nil)
                return
            }
        }
    }
    
    fileprivate func setUpViewControllers() {
        
        tabBar.unselectedItemTintColor = Service.unselectedColor
        tabBar.tintColor = Service.darkBaseColor
        
        let homeNavController = UINavigationController(rootViewController: homeController)
        homeNavController.tabBarItem.image = #imageLiteral(resourceName: "MainTabBarItemHome").withRenderingMode(.alwaysTemplate)
        homeNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "MainTabBarItemHome").withRenderingMode(.alwaysTemplate)
        
        let userNavController = UINavigationController(rootViewController: userController)
        userNavController.tabBarItem.image = #imageLiteral(resourceName: "MainTabBarItemProfile").withRenderingMode(.alwaysTemplate)
        userNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "MainTabBarItemProfile").withRenderingMode(.alwaysTemplate)
        
        viewControllers = [homeNavController, userNavController]
        
        guard let items = tabBar.items else { return }
        for item in items {
            item.imageInsets = UIEdgeInsets(top: Service.topUITabBarEdgeInset, left: Service.leftUITabBarEdgeInset, bottom: Service.bottomUITabBarEdgeInset, right: Service.rightUITabBarEdgeInset)
        }
    }
    
}

