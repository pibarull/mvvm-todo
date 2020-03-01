//
//  ToDoListView.swift
//  MVVM-todo
//
//  Created by Илья Ершов on 30/01/2020.
//  Copyright © 2020 Ilia Ershov. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import RxCocoa
import RxDataSources

struct SectionOfCustomData {
    var header: String
    var items: [Item]
}

extension SectionOfCustomData: SectionModelType {
  typealias Item = Task

   init(original: SectionOfCustomData, items: [Item]) {
    self = original
    self.items = items
  }
}


class ToDoListView: UIViewController, UIScrollViewDelegate {

    typealias ViewModelType = ToDoListViewModel
    
    // MARK: - UI
    
    @IBOutlet weak var createNewTaskButton: UIButton!
    @IBOutlet weak var noTasksLabel: UILabel!
    @IBOutlet weak var tasksTableView: UITableView!
    
    // MARK: - Properties
    
    var viewModel = ViewModelType(TaskModel())
    private var disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UpdateStatusesEveryMinute()

        configureNavigationBar()
        
        viewModel.input.getTasks.onNext(())
        
        tasksTableView.rx.setDelegate(self).disposed(by: disposeBag)
        setupViews()
        configure(with: viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.input.getTasks.onNext(())
    }
    
    // MARK: - Functions
    func configure(with viewModel: ViewModelType) {
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData>(
          configureCell: { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellToDo", for: indexPath) as! TaskTableViewCell
            
            cell.task = item
            if item.taskStatus == Task.Status.expired.rawValue {
                cell.dateLabel.textColor = UIColor(named: "customRed")
                cell.titleLabel.textColor = .black
            } else if item.taskStatus == Task.Status.undone.rawValue {
                cell.titleLabel.textColor = .black
                if Int(item.deadline.timeIntervalSince(Date())) < 43200 { // за 12 часов до дэдлайна цвет станет жёлтым
                    cell.dateLabel.textColor = UIColor(named: "customYellow")
                } else {
                    cell.dateLabel.textColor = UIColor(named: "customGreen")
                }
            } else {
                cell.dateLabel.textColor = .lightGray
            }
            
            if !item.hasDeadline {
                cell.dateLabel.isHidden = true
            } else {
                cell.dateLabel.isHidden = false
            }
            
            return cell
            })
        
        let sectionsSubject =  PublishSubject<[SectionOfCustomData]>()
        
        viewModel.output.tasks.subscribe( onNext: { tasks in
            var header1: String
            (tasks.filter{$0.taskStatus == Task.Status.expired.rawValue}.filter{$0.hasDeadline}).count == 0 ? (header1 = "") : (header1 = "Просроченные")
            var header2: String
            (tasks.filter{$0.taskStatus == Task.Status.undone.rawValue}.filter{$0.hasDeadline}).count == 0 ? (header2 = "") : (header2 = "Предстоящие")
            var header3: String
            (tasks.filter{!$0.hasDeadline}).count == 0 ? (header3 = "") : (header3 = "Без срока")
            var header4: String
            (tasks.filter{$0.taskStatus == Task.Status.done.rawValue}).count == 0 ? (header4 = "") : (header4 = "Завершённые")
            
                sectionsSubject.onNext([
                    SectionOfCustomData(header: header1, items: tasks.filter{$0.taskStatus == Task.Status.expired.rawValue}.filter{$0.hasDeadline}),
                    SectionOfCustomData(header: header2, items: tasks.filter{$0.taskStatus == Task.Status.undone.rawValue}.filter{$0.hasDeadline}),
                    SectionOfCustomData(header: header3, items: tasks.filter{$0.taskStatus == Task.Status.undone.rawValue}.filter{!$0.hasDeadline}.sorted { (lhs, rhs) -> Bool in
                            return lhs.doneAt > rhs.doneAt
                    }),
                    SectionOfCustomData(header: header4, items: tasks.filter{$0.taskStatus == Task.Status.done.rawValue}.sorted { (lhs, rhs) -> Bool in
                            return lhs.doneAt > rhs.doneAt
                    })
                ])
        }).disposed(by: disposeBag)
        
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }
        
        
        dataSource.canEditRowAtIndexPath = { dataSource, indexPath in
            return true
        }
        
        // BIND
        sectionsSubject.asObservable()
        .bind(to: tasksTableView.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        // TableView Rx staff
        tasksTableView.rx.modelSelected(Task.self)
        .asDriver()
        .drive(onNext: { [unowned self] task in
            let navigationController = self.navigationController as! TasksNavigationController
            navigationController.show(segue: .taskDetail(index: task.taskId), sender: self)
        }).disposed(by: disposeBag)
        
        
        tasksTableView.rx.modelDeselected(Task.self).subscribe(onNext: { task in
            if let selectedRowIndexPath = self.tasksTableView.indexPathForSelectedRow {
                self.tasksTableView.deselectRow(at: selectedRowIndexPath, animated: true)
            }
        }).disposed(by: disposeBag)
            
        viewModel.output.isTask.subscribe(onNext: { [unowned self] (isTask) in
            if isTask {
                self.tasksTableView.isHidden = true
                self.noTasksLabel.isHidden = false
            } else {
                self.tasksTableView.isHidden = false
                self.noTasksLabel.isHidden = true
            }
        }).disposed(by: disposeBag)
        
        createNewTaskButton.rx.tap.subscribe({ [unowned self] _ in
            let navigationController = self.navigationController as! TasksNavigationController
            navigationController.show(segue: .createTask, sender: self)
            }).disposed(by: disposeBag)
        
        self.navigationItem.rightBarButtonItem?.rx.tap.subscribe(onNext: { [unowned self] _ in
            let navigationController = self.navigationController as! TasksNavigationController
            navigationController.show(segue: .settings, sender: self)
        }).disposed(by: disposeBag)
        
        
    }
    
    private func configureNavigationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    private func setupViews(){
        tasksTableView.sectionHeaderHeight = 74
        tasksTableView.rowHeight = 96
        tasksTableView.separatorStyle = .none
        
    }
    
    private func UpdateStatusesEveryMinute() {
        TaskModel().updateStatuses()
        viewModel.input.getTasks.onNext(())
        DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) { [weak self] in
            self?.UpdateStatusesEveryMinute()
        }
    }
    
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let controller = ToDoListView.getInstance() as! ToDoListView
        controller.viewModel = viewModel
        return controller
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: - UITableViewDelegate
extension ToDoListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.tintColor = .white
        var myString: String = ""
        switch section {
        case 0:
            myString = "Просроченные"
        case 1:
            myString = "Предстоящие"
        case 2:
            myString = "Без срока"
        case 3:
            myString = "Завершённые"
        default:
            break
        }
        
        let myAttributes = [ NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 22.0)! ]
        let myAttrString = NSAttributedString(string: myString, attributes: myAttributes)
        headerView.textLabel?.attributedText = myAttrString
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        switch indexPath.section {
            case 0,1,2:
                let closeAction = UIContextualAction(style: .normal, title: .none, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

                    let cell = self.tasksTableView.cellForRow(at: indexPath) as! TaskTableViewCell
                    if let task = cell.task {
                        self.viewModel.input.taskIsDone.onNext(task)
                    } else {
                        print("Error while gettin task from cell")
                    }
                })
                closeAction.image = UIImage(named: "check")
                closeAction.backgroundColor = .systemGreen
                return UISwipeActionsConfiguration(actions: [closeAction])
            default:
                return .none
        }
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?{
        
        let modifyAction = UIContextualAction(style: .normal, title:  .none, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
    
                let cell = self.tasksTableView.cellForRow(at: indexPath) as! TaskTableViewCell
                if let task = cell.task {
                    self.viewModel.input.deleteTaskAt.onNext(cell.task!.taskId)
                } else {
                    print("Error while gettin task from cell")
                }
            })
        modifyAction.image = UIImage(named: "x")
        modifyAction.backgroundColor = .systemRed

        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
}
