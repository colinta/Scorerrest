//
//  AppDelegate.swift
//  Mainframe
//
//  Created by Colin Gray on 12/20/15.
//  Copyright © 2015 colinta. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        application.statusBarStyle = .lightContent

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        window.makeKeyAndVisible()

        let ctlr = MainViewController()
        window.rootViewController = ctlr

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

}
