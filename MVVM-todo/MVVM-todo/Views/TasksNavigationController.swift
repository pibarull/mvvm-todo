//
//  TasksNavigationController.swift
//  MVVM-todo
//
//  Created by Илья Ершов on 30/01/2020.
//  Copyright © 2020 Ilia Ershov. All rights reserved.
//

import UIKit

class TasksNavigationController: UINavigationController {

    // MARK: - segues list
    enum Segue {
        case toDoList
        case createTask
        case taskDetail(index: Int)
        case settings
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRootChild()
    }
    
    // MARK: - Configure the root controller
    
    private func configureRootChild() {
        let child = self.children[0] as! ToDoListView
        child.viewModel = ToDoListViewModel(TaskModel())
    }
    
    // MARK: - invoke a single segue
    func show(segue: Segue, sender: UIViewController) {
    switch segue {
        case .toDoList:
            let vm = ToDoListViewModel(TaskModel())
            showVC(target: ToDoListView.create(with: vm), sender: sender)
        case .createTask:
            let vm = NewTaskViewModel(TaskModel())
            showVC(target: NewTaskView.create(with: vm), sender: sender)
        case .taskDetail(let index):
            let vm = TaskDetailsViewModel(index, TaskModel())
            showVC(target: TaskDetailsView.create(with: vm), sender: sender)
        case .settings:
            showVC(target: SettingsView.create(), sender: sender)
        }
    }

}
