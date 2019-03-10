//
//  AppDelegate.swift
//  pixscape
//
//  Created by bils on 02/03/2018.
//  Copyright © 2018 Scape Technologies Limited. All rights reserved.
//

import UIKit
import ScapeKit

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
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        scapeClient.start(clientStarted: {
                            print("ScapeClient started properly")
        },
                          clientFailed: { errorMessage in
                            print("ScapeClient failed with error: \(errorMessage)")
        })
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        var initialVc: UIViewController
        if(isAppAlreadyLaunchedOnce()) {
            initialVc = ARViewController(scapeClient: scapeClient)
        } else {
            initialVc = PermissionsViewController(scapeClient: scapeClient)
        }
        
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
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        scapeClient.stop()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        scapeClient.start(clientStarted: {
                            print("ScapeClient started properly")
        },
                          clientFailed: { errorMessage in
                            print("ScapeClient failed with error: \(errorMessage)")
        })
    }

    func applicationWillTerminate(_ application: UIApplication) {
        scapeClient.terminate()
    }
}

private extension AppDelegate {
    func isAppAlreadyLaunchedOnce() -> Bool {
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "AppAlreadyLaunchedOnce"){
            print("App already launched")
            return true
        } else {
            defaults.set(true, forKey: "AppAlreadyLaunchedOnce")
            print("App launched for the first time")
            return false
        }
    }
}

