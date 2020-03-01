//
//  ToDoTask.swift
//  MVVM-todo
//
//  Created by Илья Ершов on 30/01/2020.
//  Copyright © 2020 Ilia Ershov. All rights reserved.
//

import RealmSwift

class Task: Object {
    
    enum Status: String {
        case undone = "Предстоящие"
        case done = "Завершённые"
        case expired = "Просроченные"
    }

    @objc dynamic var taskId: Int = Date().hashValue
    @objc dynamic var title: String = ""
    @objc dynamic var descript: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var doneAt: Date = Date()
    @objc dynamic var latitude: Float = 0.0
    @objc dynamic var longitude: Float = 0.0
    @objc dynamic var deadline: Date = Date()
    @objc dynamic var taskStatus: String = ""
    @objc dynamic var hasDeadline: Bool = false
    
    convenience init(title: String, descript: String, latitude: Float = 0.0, longitude: Float = 0.0, deadline: Date, taskStatus: Status = .undone, hasDeadline: Bool = false) {
        self.init()
        self.title = title
        self.descript = descript
        self.latitude = latitude
        self.longitude = longitude
        self.deadline = deadline
        self.taskStatus = taskStatus.rawValue
        self.hasDeadline = hasDeadline
    }
    
    override class func primaryKey() -> String? {
        return "taskId"
    }
}

