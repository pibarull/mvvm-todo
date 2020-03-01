//
//  AppDelegate.swift
//  MVVM-todo
//
//  Created by Илья Ершов on 30/01/2020.
//  Copyright © 2020 Ilia Ershov. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // configure Realm
        RealmFunctions.shared.configureMigration()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                
                let HHToNotice = UserDefaults.standard.integer(forKey: "HHToNotice")
                let mmToNotice = UserDefaults.standard.integer(forKey: "mmToNotice")

                if HHToNotice == 0 && mmToNotice == 0 {
                    NotificationHandler.shared().notificationEnabled = true
                } else {
                    NotificationHandler.shared().notificationEnabled = false
                }
            } else {
                // User didn't allow to notificate him
                NotificationHandler.shared().notificationEnabled = false
            }
        }
        
        FirebaseApp.configure()
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let application = UIApplication.shared
        let userInfo = response.notification.request.content.userInfo
        
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            if let taskId  = userInfo["taskId"] {
                print(taskId)
                
                //TODO: - Сделать переход по тапу на уведомление
                
//                let navigationController = TasksNavigationController()
//                let vm = ToDoListViewModel(TaskModel())
//
//                var window = UIWindow()
//                window = UIWindow(frame: UIScreen.main.bounds)
//                window.rootViewController = ToDoListView.create(with: vm)
//                window.makeKeyAndVisible()
//
//                navigationController.show(segue: .taskDetail(index: taskId as! Int), sender: window.rootViewController!)
            }
            
            

        }
        
//        if let ticketsPlusHours = userInfo["tickets_plus_hours"] {
//            print("Осталось до окончания подписки: \(ticketsPlusHours)")
//            let ticketsPlusHoursInt = JSON(userInfo)["tickets_plus_hours"].intValue
//
//            if ticketsPlusHoursInt == 24 {
//                configureBubble(ticketsPlusMinutes: 2)
//            } else {
//                configureBubble(ticketsPlusMinutes: 1442)
//            }
//
//            if(application.applicationState == .active){
//                print("user tapped the notification bar when the app is in foreground")
//                NotificationCenter.default.post(name: Notification.Name("didReceivePushNotification"), object: nil)
//            }
//
//            if(application.applicationState == .inactive)
//            {
//                print("user tapped the notification bar when the app is in background")
//                NotificationCenter.default.post(name: Notification.Name("didReceivePushNotification"), object: nil)
//            }
//        }
        
        completionHandler()
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

