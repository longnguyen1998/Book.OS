//
//  AppDelegate.swift
//  MyLocations_App
//
//  Created by Nguyen Dinh Thanh Long on 11/6/19.
//  Copyright © 2019 Nguyen Dinh Thanh Long. All rights reserved.
//

import UIKit
import CoreData

let delegate = UIApplication.shared.delegate as! AppDelegate


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: {
            storeDescription, error in
            if let error = error {
                fatalError("Could load data store: \(error)")
            }
        })
        return container
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = persistentContainer.viewContext

    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabController = storyboard.instantiateViewController(identifier: "UITabBarController") as! UITabBarController
        window?.rootViewController = tabController
        
        if let tabViewControllers = tabController.viewControllers {
            let navController = tabViewControllers[0]
                as! UINavigationController
            let controller = navController.viewControllers.first
                as! CurrentLocationViewController
            controller.managedObjectContext = managedObjectContext
        }
        print(applicationDocumentsDirectory)
        listenForFatalCoreDataNotifications()
        return true
    }


    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate {
    // MARK:- Helper methods
    func listenForFatalCoreDataNotifications() {
        // 1
        NotificationCenter.default.addObserver(
            forName: CoreDataSaveFailedNotification,
            object: nil, queue: OperationQueue.main,
            using: { notification in
                // 2
                let message = """
    There was a fatal error in the app and it cannot continue.
    Press OK to terminate the app. Sorry for the inconvenience.
    """
                // 3
                let alert = UIAlertController(
                    title: "Internal Error", message: message,
                    preferredStyle: .alert)
                
                // 4
                let action = UIAlertAction(title: "OK",
                                           style: .default) { _ in
                                            let exception = NSException(
                                                name: NSExceptionName.internalInconsistencyException,
                                                reason: "Fatal Core Data error", userInfo: nil)
                                            exception.raise()
                }
                alert.addAction(action)
                
                // 5
                let tabController = self.window!.rootViewController!
                tabController.present(alert, animated: true,
                                      completion: nil)
        })
    }
}

