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
    let summaryController: SummaryController = SummaryController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewControllers()
        
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
        
        let summaryNavController = UINavigationController(rootViewController: summaryController)
        summaryNavController.tabBarItem.image = #imageLiteral(resourceName: "graph").withRenderingMode(.alwaysTemplate)
        summaryNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "graph").withRenderingMode(.alwaysTemplate)
        
        viewControllers = [homeNavController,summaryNavController,userNavController]
        
        guard let items = tabBar.items else { return }
        for item in items {
            item.imageInsets = UIEdgeInsets(top: Service.topUITabBarEdgeInset, left: Service.leftUITabBarEdgeInset, bottom: Service.bottomUITabBarEdgeInset, right: Service.rightUITabBarEdgeInset)
        }
    }
    
}

