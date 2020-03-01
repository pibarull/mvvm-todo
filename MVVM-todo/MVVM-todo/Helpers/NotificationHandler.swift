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
            (HH, mm) = task.deadline.getFormattedTimeInHHmm()
            (YYYY, MM, dd) = task.deadline.getFormattedTimeInYYYYMMdd()
             let HHToNotice = UserDefaults.standard.integer(forKey: "HHToNotice")
            let mmToNotice = UserDefaults.standard.integer(forKey: "mmToNotice")
            HH = HH - HHToNotice
            mm = mm - mmToNotice
        } else {
            print("Error while getting task")
        }
        content.categoryIdentifier = "alarm"
        content.userInfo = ["taskId": taskId]
        let id  = content.userInfo["taskId"]
        
        content.sound = UNNotificationSound.default

        if mm < 0 {
            HH -= 1
            mm = 60 + mm
        }
        if HH < 0 {
            dd -= 1
            HH = 24 + HH
        }
        if dd < 0 {
            MM -= 1
            //TODO: - Сделать проверку на количество дней в месяце (31,30,28)
            dd = 31 + dd
        }
        if MM < 0 {
            YYYY -= 1
            MM = 12 + MM
        }
        var dateComponents = DateComponents()
        
//        print("HH to notice = \(HH)")
//        print("mm to notice = \(mm)")
//        print("Year to notice = \(YYYY)")
//        print("Month to notice = \(MM)")
//        print("Day to notice = \(dd)")
    
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
