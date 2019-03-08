//
//  AppDelegate.swift
//  pixscape
//
//  Created by bils on 02/03/2018.
//  Copyright © 2018 Scape Technologies Limited. All rights reserved.
//

import UIKit
import ScapeKit
import Fabric
import Crashlytics

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var scapeClient: SCKScapeClient = {
        return SCKScape.scapeClientBuilder
            .withDebugSupport(false)
            .withApiKey("")
            .withArSupport(true)
            .build()
    }()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        
        scapeClient.scapeClientObserver = self
        scapeClient.start()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        var initialVc: UIViewController
        #if DEBUG
        initialVc = ARViewController(scapeClient: scapeClient)
        #else
        initialVc = PinViewController(scapeClient: scapeClient)
        #endif
        
        let navController = UINavigationController(rootViewController: initialVc)
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.tintColor = UIColor.primary.darken(percent: 0.5)
        
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        if(scapeClient.isStarted) {
            scapeClient.stop()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if(scapeClient.isStarted) {
            scapeClient.stop()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if(!scapeClient.isStarted) {
            scapeClient.start()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        scapeClient.terminate()
    }
}

extension AppDelegate: SCKScapeClientObserver {
    func onClientStarted(_ scapeClient: SCKScapeClient) {
        
    }
    
    func onClientStopped(_ scapeClient: SCKScapeClient) {
        
    }
    
    func onClientFailed(_ scapeClient: SCKScapeClient, errorMessage: String) {
        
    }
}

func isAppAlreadyLaunchedOnce() -> Bool {
    let defaults = UserDefaults.standard
    if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
        print("App already launched")
        return true
    } else {
        defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
        print("App launched first time")
        return false
    }
}

