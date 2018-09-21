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
import FirebaseStorage
import FirebaseDatabase
import SwiftSpinner
import SwiftyBeaver
import EventKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, LoginFlowWorker {

    var window: UIWindow?
    var eventStore: EKEventStore?
    var mainTabBarController: MainTabBarController?
    let log = SwiftyBeaver.self

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        //Configure Logging Framework
        let console = ConsoleDestination()
        let file = FileDestination()
        let cloud = SBPlatformDestination(appID: SwiftyBeaverCredentials.appID, appSecret: SwiftyBeaverCredentials.appSecret, encryptionKey: SwiftyBeaverCredentials.encryptionKey)
        log.addDestination(console)
        log.addDestination(file)
        log.addDestination(cloud)

        //Configure Firebase
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseConfiguration.shared.analyticsConfiguration.setAnalyticsCollectionEnabled(false)
        FirebaseApp.configure()
        //Enable Disk Persistence
        Database.database().isPersistenceEnabled = true

        //Configure Google
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self

        //Continue setup
        window = UIWindow()

        //Check if first time opening or if UITesting, if so onboard
        let defaults = UserDefaults.standard

        if (defaults.string(forKey: "isAppAlreadyLaunchedOnce") == nil) ||
            CommandLine.arguments.contains("-ui_tests") {
            log.info("OnBoarding Triggered")
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            let onBoard = OnBoardController()
            let onBoardConrollerNav = UINavigationController(rootViewController: onBoard)
            window?.rootViewController = onBoardConrollerNav
            window?.makeKeyAndVisible()
        } else {
            log.info("App Previously Launched, Ignoring OnBoarding...")
            handleLogin(withWindow: window)
        }
        return true
    }

    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication,
            annotation: annotation)
    }

    /**
        Relevant code used to sign in a user via Google. Really not
        a fan of the fact it exists inside AppDelegate, but hey, this is
        the suggested solution by Google.
    */
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        SwiftSpinner.show("Signing In via Google")

        if let error = error {
            SwiftSpinner.show("Error Signing In via Google...").addTapHandler({
                SwiftSpinner.hide()
            })
            self.log.error("Error signing in via Google: \(error.localizedDescription)")
            return
        }

        guard let authentication = user.authentication else {
            SwiftSpinner.show("Error Authenticating User...").addTapHandler({
                SwiftSpinner.hide()
            })
            self.log.error("There was a problem authenticating the user via Google...")
            return
        }

        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
            accessToken: authentication.accessToken)

        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            if let error = error {
                SwiftSpinner.show("Error Signing In via Google...").addTapHandler({
                    SwiftSpinner.hide()
                })
                self.log.error("Error signing in via Google: \(error.localizedDescription)")
                return
            }
            guard let name = user?.user.displayName, let email = user?.user.email,
                let profilePicUrl = user?.user.photoURL?.absoluteString,
                let uid = Auth.auth().currentUser?.uid else {
                    SwiftSpinner.show("Error Retrieving User Information...").addTapHandler({
                        SwiftSpinner.hide()
                    })
                    self.log.error("Error retrieving users unique identifier...")
                    return
            }
            /*
             Important to use observeSingleEvent here as we don't want the callback to be executed
             multiple times. 
            */
            Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.hasChild(uid) {
                    self.log.info("Creating new user")
                    let altProfilePicURL = Service.defaultProfilePicUrl
                    let dictionaryValues = ["name": name, "email": email,
                        "profileImageURL": profilePicUrl, "altProfileImageURL": altProfilePicURL,
                        "birthdate": "Not set", "gender": "Not set", "height": "Not set",
                        "weight": "Not set"]
                    let values = [uid: dictionaryValues]
                    Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (error, ref) in
                        if let error = error {
                            SwiftSpinner.show("Error Signing Up...").addTapHandler({
                                self.log.error("Error signing up with Google: \(error.localizedDescription)")
                                Service.notifyStaffOfError(#file, "\(#function) \(#line):  Error signing up with Google: \(error.localizedDescription)")
                            })
                            return
                        }
                        self.completeSignIn(uid)
                    })
                } else {
                    self.log.info("Google Sign in succesful")
                    self.completeSignIn(uid)
                }
            })

        }
    }
    /**
        Completes a users login on success, by
        performing the necessary steps needed to
        present the mainTabBar.
     
        - parameter : uid, the users unique id.
    */
    func completeSignIn(_ uid: String) {
        SwiftSpinner.hide()
        //present mainTabBar
        self.handleLogin(withWindow: self.window)
    }


    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        self.log.error("\(user.userID) disconnected from the app with error: \(error.localizedDescription)")
        Service.notifyStaffOfError(#file, "\(#function) \(#line):  disconnected from the app with error: \(error.localizedDescription)")
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

}


