//
//  ToDoTaskModel.swift
//  MVVM-todo
//
//  Created by Илья Ершов on 30/01/2020.
//  Copyright © 2020 Ilia Ershov. All rights reserved.
//

import RealmSwift
import RxSwift
import RxRealm

protocol TaskModelProtocol {
    func addTask(task: Task)
    func getTasks() -> Observable<([Task], RealmChangeset?)>
    func getTask(by taskId: Int) -> Task?
    func deleteTask(by id: Int)
    func deleteTasks()
    func updateTask(by id: Int, with newTitle: String, with newDescript: String)
    func taskDone(by id: Int)
    func updateStatuses()
    func updateStatus(by id: Int)
}

class TaskModel: TaskModelProtocol {
    lazy var realm = try! Realm()
    
    func addTask(task: Task) {
        do {
            try realm.write {
                realm.add(task, update: .modified)
            }
        } catch (let error) {
            print(error)
        }
    }
    
    func getTasks() -> Observable<([Task], RealmChangeset?)> {
        return Observable.arrayWithChangeset(from: realm.objects(Task.self))
    }
    
    func getTask(by taskId: Int) -> Task? {
        return realm.object(ofType: Task.self, forPrimaryKey: taskId)
    }
    
    func deleteTask(by id: Int) {
        if let taskToDelete =  getTask(by: id) {
            try! realm.write {
                realm.delete(taskToDelete)
            }
        }
    }
    
    func deleteTasks() {
        let tasks = realm.objects(Task.self)
        
        do {
            try realm.write {
                realm.delete(tasks)
            }
        } catch (let error) {
            print(error)
        }
    }
    
    func updateTask(by id: Int, with newTitle: String, with newDescript: String) {
        try! realm.write {
            let taskToChange = getTask(by: id)
            taskToChange?.title = newTitle
            taskToChange?.descript = newDescript
        }
    }
    
    func taskDone(by id: Int) {
        try! realm.write {
            let taskToChange = getTask(by: id)
            taskToChange?.doneAt = Date()
            taskToChange?.taskStatus = Task.Status.done.rawValue
        }
    }

    func updateStatuses() {
        var taskIds: [Int] = [] // Ids of statuses to change (expired tasks)
        
        getTasks().subscribe(onNext: { (tasks) in
            tasks.0.forEach { (task) in
                if task.hasDeadline && task.deadline < Date() && task.taskStatus != Task.Status.done.rawValue {
                    taskIds.append(task.taskId)
                }
            }
        })
        for taskId in taskIds {
            updateStatus(by: taskId)
        }
    }
    
    func updateStatus(by id: Int) {
        try! realm.write {
            let taskToChange = getTask(by: id)
            taskToChange?.taskStatus = Task.Status.expired.rawValue
        }
    }
    
}
