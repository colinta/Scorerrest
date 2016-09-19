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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.statusBarStyle = .LightContent

        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window = window

        window.makeKeyAndVisible()

        let ctlr = MainViewController()
        window.rootViewController = ctlr

        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

}
