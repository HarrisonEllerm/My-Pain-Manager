//
//  AppDelegate.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 17/04/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import JGProgressHUD
import FirebaseStorage
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, LoginFlowWorker  {
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    var window: UIWindow?
    var mainTabBarController: MainTabBarController?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Configure Firebase
        FirebaseApp.configure()
        
        //Client ID for Google Sign In
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        // Override point for customization after application launch.
        window = UIWindow()
        window?.makeKeyAndVisible()
        handleLogin(withWindow: window)
        
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,annotation: [:])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        hud.textLabel.text = "Signing In via Google..."
        hud.detailTextLabel.text = ""
        
        if let topVC = getTopViewController() {
            hud.show(in: topVC.view, animated: true)
        }
        if let error = error {
            Service.dismissHud(self.hud, text: "Error", detailText: "Error signing in.", delay: 3)
            print(error)
            return
        }
        
        guard let authentication = user.authentication else {
            Service.dismissHud(self.hud, text: "Error", detailText: "Failed to authenticate.", delay: 3)
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                Service.dismissHud(self.hud, text: "Error", detailText: "Failed to authenticate.", delay: 3)
                print(error)
                return
            }
           
            guard let name = user?.displayName, let email = user?.email,
                            let profilePicUrl = user?.photoURL?.absoluteString,
                            let uid = Auth.auth().currentUser?.uid else {
                Service.dismissHud(self.hud, text: "Error", detailText: "Error finding information for user.", delay: 3)
                return
            }
            let dictionaryValues = ["name": name, "email": email, "profileImageURL": profilePicUrl]
            let values = [uid: dictionaryValues]
            
            Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (error, ref) in
                if let error = error {
                    Service.dismissHud(self.hud, text: "Sign up error.", detailText: error.localizedDescription, delay: 3)
                    return
            }
            /*
                Google sign in ok, allow slight delay to dismiss hud, then push new page.
            */
            self.hud.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                //present mainTabBar
                self.handleLogin(withWindow: self.window)
                }
            })
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func refreshApplicationState() {
        print("Refreshing Applicaton State....")
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let rootViewController = MainTabBarController()
        UIView.transition(with: self.window!, duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromLeft, animations: {
            self.window?.rootViewController = rootViewController
             self.window?.makeKeyAndVisible()
        }, completion: nil)
    }
}
