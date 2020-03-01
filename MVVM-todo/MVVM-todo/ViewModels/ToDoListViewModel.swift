//
//  ToDoListViewModel.swift
//  MVVM-todo
//
//  Created by Илья Ершов on 30/01/2020.
//  Copyright © 2020 Ilia Ershov. All rights reserved.
//

import RxSwift

class ToDoListViewModel {
    struct Input {
        let getTasks: AnyObserver<Void>
        let taskIsDone: AnyObserver<Task>
        let deleteTaskAt: AnyObserver<Int>
    }
    
    struct Output {
        let isTask: Observable<Bool> //Does any task exist
        let tasks: Observable<[Task]>
        let task: Observable<Task>
    }
    
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    // MARK: - Private properties
    
    // input
    private let getTasksSubject = PublishSubject<Void>()
    private let taskIsDoneSubject = PublishSubject<Task>()
    private let deleteTaskAtSubject = PublishSubject<Int>()
    // output
    private let isTaskSubject = BehaviorSubject<Bool>(value: false)
    private let tasksSubject = BehaviorSubject<[Task]>(value: [Task]())
    private var taskSubject = PublishSubject<Task>()
    
    private let disposeBag = DisposeBag()
    
    // Services
    private let taskModel: TaskModelProtocol
    
    //MARK: Init
    init(_ taskModel: TaskModelProtocol){
        input = Input(getTasks: getTasksSubject.asObserver(),
                      taskIsDone: taskIsDoneSubject.asObserver(),
                      deleteTaskAt: deleteTaskAtSubject.asObserver())
        output = Output(isTask: isTaskSubject.asObservable(),
                        tasks: tasksSubject.asObservable(),
                        task: taskSubject.asObservable())
        
        self.taskModel = taskModel
        
        getTasksSubject.subscribe(onNext: {
            self.fetchTasks()
        })
        
        deleteTaskAtSubject.subscribe(onNext: { (taskId) in
            taskModel.deleteTask(by: taskId)
            NotificationHandler.shared().center.removePendingNotificationRequests(withIdentifiers: [String(taskId)])
        })
        
        taskIsDoneSubject.subscribe(onNext: { (task) in
            taskModel.taskDone(by: task.taskId)
            NotificationHandler.shared().center.removePendingNotificationRequests(withIdentifiers: [String(task.taskId)])
        })
        
        
    }
    
    //MARK: Functions
    func fetchTasks() {
        taskModel.updateStatuses()
        taskModel.getTasks()
            .subscribe({ [weak self] tasks in
                if (tasks.element?.0.isEmpty)! { // No tasks
                    self?.isTaskSubject.onNext(true)
                } else {
                    if let tasks = tasks.element?.0 {
                        self?.isTaskSubject.onNext(false)
                        
                        self?.tasksSubject.onNext(
                            tasks.sorted { (lhs, rhs) -> Bool in
                                return lhs.deadline < rhs.deadline
                        })
                    }
                }
            }).disposed(by: disposeBag)
    }
}
