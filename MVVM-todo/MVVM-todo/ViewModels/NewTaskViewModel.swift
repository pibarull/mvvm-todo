//
//  NewTaskViewModel.swift
//  MVVM-todo
//
//  Created by Илья Ершов on 11/02/2020.
//  Copyright © 2020 Ilia Ershov. All rights reserved.
//

import RxSwift
import CoreLocation

class NewTaskViewModel {
    struct Input {
        let savePressed: AnyObserver<Task>
        let setLocation: AnyObserver<(CLLocationDegrees, CLLocationDegrees)>
    }
    
    struct Output {
        let shouldDismiss: Observable<Void>
    }
    
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    // MARK: - Private properties
    
    // input
    private let savePressedSubject = PublishSubject<Task>()
    private let setLocationSubject = PublishSubject<(CLLocationDegrees, CLLocationDegrees)>()
    // output
    private let shouldDismissSubject = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    
    private var latitude: Float = 0.0
    private var longitude: Float = 0.0
    
    // Services
    private let taskModel: TaskModelProtocol
    
    init(_ taskModel: TaskModelProtocol){
        input = Input(savePressed: savePressedSubject.asObserver(),
                      setLocation: setLocationSubject.asObserver())
        output = Output(shouldDismiss: shouldDismissSubject.asObservable())
        
        self.taskModel = taskModel
                
        savePressedSubject.subscribe(onNext: { [unowned self] task in
            task.latitude = self.latitude
            task.longitude = self.longitude
            self.taskModel.addTask(task: task)
            if !NotificationHandler.shared().notificationEnabled && task.hasDeadline {
                NotificationHandler.shared().scheduleNotification(by: task.taskId)
            }
            self.shouldDismissSubject.onNext(())
            }).disposed(by: disposeBag)
        
        setLocationSubject.subscribe(onNext: { [unowned self] (coord) in
            self.latitude = Float(coord.0)
            self.longitude = Float(coord.1)
        })
        
    }
}
