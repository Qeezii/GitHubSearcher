//
//  AppDelegate.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 05.05.2023.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let controllerFactory = ControllerFactory()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = controllerFactory.makeMainTabBarController()
        window?.makeKeyAndVisible()
        return true
    }
}
