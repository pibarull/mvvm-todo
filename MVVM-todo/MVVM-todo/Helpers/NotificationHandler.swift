//
//  NotificationHandler.swift
//  MVVM-todo
//
//  Created by Appvelox on 25/02/2020.
//  Copyright © 2020 Ilia Ershov. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationHandler {
    
    private static var notificationHandler: NotificationHandler?
    
    static func shared() -> NotificationHandler {
        if notificationHandler == nil {
            notificationHandler = NotificationHandler()
        }
        return notificationHandler!
    }
    
    private init() {}
    
    public var notificationEnabled: Bool = true
    public var center = UNUserNotificationCenter.current()
  
    func scheduleNotification(by taskId: Int) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        
        content.title = "Скоро заканчивается срок выполнения"
        var HH: Int = 0
        var mm: Int = 0
        var YYYY: Int = 0
        var MM: Int = 0
        var dd: Int = 0
        if let task = TaskModel().getTask(by: taskId) {
            content.body = task.title
            let HHToNotice = UserDefaults.standard.integer(forKey: "HHToNotice")
            let mmToNotice = UserDefaults.standard.integer(forKey: "mmToNotice")
            
            let timeInterval = -(60*mmToNotice + 60*60*HHToNotice)
            let date = task.deadline.addingTimeInterval(TimeInterval(timeInterval))
            (HH, mm) = date.getFormattedTimeInHHmm()
            (YYYY, MM, dd) = date.getFormattedTimeInYYYYMMdd()
            
        } else {
            print("Error while getting task")
        }
        content.categoryIdentifier = "alarm"
        content.userInfo = ["taskId": taskId]
        let id  = content.userInfo["taskId"]
        
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
    
        dateComponents.year = YYYY
        dateComponents.month = MM
        dateComponents.day = dd
        dateComponents.hour = HH
        dateComponents.minute = mm
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: String(taskId), content: content, trigger: trigger)
        center.add(request)
    }
    
}
