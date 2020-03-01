//
//  TaskDetailsModelView.swift
//  MVVM-todo
//
//  Created by Илья Ершов on 11/02/2020.
//  Copyright © 2020 Ilia Ershov. All rights reserved.
//

import RxSwift

class TaskDetailsViewModel {
    struct Input {
        let getTask: AnyObserver<Void>
        let editPressed: AnyObserver<Bool>
        let updateTask: AnyObserver<(String, String)>
        let donePressed: AnyObserver<Void>
        let deletePressed: AnyObserver<Void>
    }
    
    struct Output {
        let task: Observable<Task>
        let setViewsOnSaveMode: Observable<Void>
        let setViewsOnEditMode: Observable<Void>
        let setDoneViewsStyle: Observable<Task>
    }
    
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    // MARK: - Private properties
    
    // input
    private let getTaskSubject = PublishSubject<Void>()
    private let editPressedSubject = PublishSubject<Bool>()
    private let updateTaskSubject = PublishSubject<(String, String)>()
    private let donePressedSubject = PublishSubject<Void>()
    private let deletePressedSubject = PublishSubject<Void>()
    // output
    private let taskSubject = BehaviorSubject<Task>(value: Task())
    private let setViewsOnSaveModeSubject = PublishSubject<Void>()
    private let setViewsOnEditModeSubject = PublishSubject<Void>()
    private let setDoneViewsStyleSubject = PublishSubject<Task>()
    
    private let disposeBag = DisposeBag()
    
    // Services
    private let taskModel: TaskModelProtocol
    
    init(_ taskId: Int,_ taskModel: TaskModelProtocol){
        input = Input(getTask: getTaskSubject.asObserver(),
                      editPressed: editPressedSubject.asObserver(),
                      updateTask: updateTaskSubject.asObserver(),
                      donePressed: donePressedSubject.asObserver(),
                      deletePressed: deletePressedSubject.asObserver())
        output = Output(task: taskSubject.asObservable(),
                        setViewsOnSaveMode: setViewsOnSaveModeSubject.asObservable(),
                        setViewsOnEditMode: setViewsOnEditModeSubject.asObservable(),
                        setDoneViewsStyle: setDoneViewsStyleSubject.asObservable())
        
        self.taskModel = taskModel
        
        getTaskSubject.subscribe(onNext: { [unowned self] _ in
            self.taskSubject.onNext(taskModel.getTask(by: taskId)!)
            }).disposed(by: disposeBag)
        
        editPressedSubject.subscribe(onNext: { [unowned self] (isEditing) in
            if isEditing {
                self.setViewsOnEditModeSubject.onNext(())
            } else {
                self.setViewsOnSaveModeSubject.onNext(())
            }
        })
        
        updateTaskSubject.subscribe(onNext: { (newTitle, newDescription) in
            taskModel.updateTask(by: taskId, with: newTitle, with: newDescription)
        })
        
        donePressedSubject.subscribe(onNext: { [unowned self] _ in
            taskModel.taskDone(by: taskId)
            if let task = taskModel.getTask(by: taskId) {
                self.setDoneViewsStyleSubject.onNext(task)
            } else {
                print("Error while getting task from realm")
            }
        })
        
        deletePressedSubject.subscribe(onNext: { [unowned self] _ in
            taskModel.deleteTask(by: taskId)
        })
        
        
    }
}
