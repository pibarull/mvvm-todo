//
//  TaskDetailsView.swift
//  MVVM-todo
//
//  Created by Илья Ершов on 31/01/2020.
//  Copyright © 2020 Ilia Ershov. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import RxCocoa
import MapKit


class TaskDetailsView: UIViewController {

    typealias ViewModelType = TaskDetailsViewModel
    
    var viewModel: ViewModelType!
    
    private var isEditingMode: Bool = false
    private var taskExpired: Bool = false
    private var initialTitle: String = ""
    private var initialDescript: String = ""
    private var keyboardHeight: CGFloat!
    private var disposeBag = DisposeBag()
    

    @IBOutlet weak var titleTextConstraing: NSLayoutConstraint!
    @IBOutlet weak var descriptTextConstraing: NSLayoutConstraint!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var createdAtDateLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var coordinatesLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardOnTap()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        titleTextView.delegate = self
        descriptionTextView.delegate = self
        
        configureNavigationBar()
        viewModel.input.getTask.onNext(())
        
        setViews()
        configure(with: viewModel)
    }
    
    func configure(with viewModel: ViewModelType) {
        
        viewModel.output.task.subscribe(onNext: { [weak self] (task) in
            if let strongSelf = self {
                
                if !task.hasDeadline {
                    strongSelf.dateLabel.isHidden = true
                }
                if task.taskStatus == Task.Status.expired.rawValue {
                    strongSelf.taskExpired = true
                    strongSelf.title = "ПРОСРОЧЕНА"
                    strongSelf.dateLabel.textColor = UIColor(named: "customRed")
                } else { // set yellow color
                    if Int(task.deadline.timeIntervalSince(Date())) < 43200 {
                        strongSelf.dateLabel.textColor = UIColor(named: "customYellow")
                    }
                }
                if task.taskStatus == Task.Status.done.rawValue {
                    strongSelf.setDoneViewsStyle(with: task)
                } else {
                    strongSelf.titleTextView.text = task.title
                    strongSelf.descriptionTextView.text = task.descript     
                }
                if(task.latitude == 0 && task.longitude == 0) {
                    strongSelf.mapView.isHidden = true
                    strongSelf.coordinatesLabel.isHidden = true
                } else {
                    strongSelf.centerMapOnLocation(location: CLLocation(latitude: CLLocationDegrees(exactly: task.latitude)!, longitude: CLLocationDegrees(exactly: task.longitude)!))
                    let artwork = Artwork(title: task.title,
                      locationName: "",
                      discipline: "",
                      coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: task.latitude)!, longitude: CLLocationDegrees(exactly: task.longitude)!)
                    )
                    strongSelf.mapView.addAnnotation(artwork)
                }
                strongSelf.initialTitle = task.title
                strongSelf.initialDescript = task.descript
                strongSelf.coordinatesLabel.text = "Координаты: \(task.latitude), \(task.longitude)"
                strongSelf.dateLabel.text = task.deadline.getFormattedDate()
                strongSelf.createdAtDateLabel.text = task.createdAt.getFormattedDate()
            }
            }).disposed(by: disposeBag)
        
        self.navigationItem.rightBarButtonItem?.rx.tap.subscribe(onNext: { [weak self] _ in
            if let strongSelf = self {
                if !strongSelf.titleTextView.text.isEmpty && !strongSelf.descriptionTextView.text.isEmpty {
                    
                    viewModel.input.editPressed.onNext(strongSelf.isEditingMode)
                    strongSelf.isEditingMode = !strongSelf.isEditingMode
                    
                } else {
                    System.showSystemAlert(vc: strongSelf,
                                           title: "Все поля должны быть заполнены",
                                           message: nil,
                                           actionOneTitle: "Ок",
                                           actionOneStyle: .default)
                }
            }
        }).disposed(by: disposeBag)
        
        //Configure save screen
        viewModel.output.setViewsOnSaveMode.subscribe(onNext: { [weak self] _ in
            if let strongSelf = self {
                strongSelf.title = "РЕДАКТИРОВАНИЕ"
                strongSelf.navigationItem.rightBarButtonItem?.image = .none
                strongSelf.navigationItem.rightBarButtonItem?.title = "Сохранить"
                
                //Handle discard button action
                strongSelf.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .plain, target: nil, action: nil)
                strongSelf.navigationItem.leftBarButtonItem?.tintColor = .black
                strongSelf.navigationItem.leftBarButtonItem?.rx.tap.subscribe(onNext: { [weak self] _ in
                    if let strongSelf = self {
                        strongSelf.titleTextView.text = strongSelf.initialTitle
                        strongSelf.descriptionTextView.text = strongSelf.initialDescript
                        
                        viewModel.input.editPressed.onNext(strongSelf.isEditingMode)
                        strongSelf.isEditingMode = !strongSelf.isEditingMode
                        
                        strongSelf.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "chevron-left"), style: .plain, target: nil, action: #selector(strongSelf.navigationController?.popViewController(animated:)))
                        strongSelf.navigationItem.leftBarButtonItem?.tintColor = .black
                    }
                })
                
                strongSelf.titleLabel.isHidden = false
                strongSelf.descriptionLabel.isHidden = false
                
                strongSelf.titleTextView.backgroundColor = UIColor(named: "enterTextColor")
                strongSelf.titleTextView.isEditable = true
                
                strongSelf.descriptionTextView.backgroundColor = UIColor(named: "enterTextColor")
                strongSelf.descriptionTextView.isEditable = true
                
                strongSelf.doneButton.isHidden = true
                strongSelf.deleteButton.isHidden = true
                
                strongSelf.titleTextConstraing.constant = 56
                strongSelf.descriptTextConstraing.constant = 43
            }
            }).disposed(by: disposeBag)
        
        //Configure edit screen
        viewModel.output.setViewsOnEditMode.subscribe(onNext: { [weak self] _ in
            
            if let strongSelf = self {
                
                let newTaskData = (strongSelf.titleTextView.text!, strongSelf.descriptionTextView.text!)
                strongSelf.viewModel.input.updateTask.onNext(newTaskData)
                
                if newTaskData.0 != "" {
                    strongSelf.initialTitle = newTaskData.0
                }
                if newTaskData.1 != "" {
                    strongSelf.initialDescript = newTaskData.1
                }
                
                strongSelf.title = "ЗАДАЧА"
                strongSelf.navigationItem.rightBarButtonItem?.title = .none
                strongSelf.navigationItem.rightBarButtonItem?.image = UIImage(named: "createIcon")
                
                strongSelf.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "chevron-left"), style: .plain, target: nil, action: #selector(strongSelf.navigationController?.popViewController(animated:)))
                strongSelf.navigationItem.leftBarButtonItem?.tintColor = .black
                
                strongSelf.titleLabel.isHidden = true
                strongSelf.descriptionLabel.isHidden = true
                
                strongSelf.titleTextView.backgroundColor = .white
                strongSelf.titleTextView.isEditable = false
                
                strongSelf.descriptionTextView.backgroundColor = .white
                strongSelf.descriptionTextView.isEditable = false
                
                strongSelf.doneButton.isHidden = false
                strongSelf.deleteButton.isHidden = false
                
                strongSelf.titleTextConstraing.constant = 10
                strongSelf.descriptTextConstraing.constant = 32
            }
            
        }).disposed(by: disposeBag)
        
        doneButton.rx.tap.subscribe(onNext: { [weak self] _ in
            if let strongSelf = self {
                System.showSystemAlert(vc: strongSelf,
                                       title: "Вы уверены, что хотите отметить эту задачу как выполненную?",
                                       message: nil,
                                       actionOneTitle: "Да",
                                       actionOneStyle: .default,
                                       actionOneHandler: { alert in
                                            viewModel.input.donePressed.onNext(())
                                        }, actionTwoTitle: "Отмена")
            }
        }).disposed(by: disposeBag)
        
        deleteButton.rx.tap.subscribe(onNext: { [weak self] _ in
            if let strongSelf = self {
                System.showSystemAlert(vc: strongSelf,
                                       title: "Вы уверены, что хотите удалить задачу?",
                                       message: nil,
                                       actionOneTitle: "Да",
                                       actionOneStyle: .default,
                                       actionOneHandler: { alert in
                                            viewModel.input.deletePressed.onNext(())
                                        strongSelf.navigationController?.popViewController(animated: true)
                                        }, actionTwoTitle: "Отмена")
            }
        }).disposed(by: disposeBag)
        
        viewModel.output.setDoneViewsStyle.subscribe(onNext: { [unowned self] (task) in
            self.setDoneViewsStyle(with: task)
        }).disposed(by: disposeBag)
    }
    
    private func configureNavigationBar() {
        let rightButton = UIBarButtonItem(image: UIImage(named: "createIcon"), style: .plain, target: self, action: nil)
        rightButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    private func setViews() {
        self.title = "ЗАДАЧА"
        
        self.dateLabel.textColor = UIColor(named: "customGreen")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "chevron-left"), style: .plain, target: nil, action: #selector(self.navigationController?.popViewController(animated:)))
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        self.descriptionTextView.layer.cornerRadius = 5
        self.titleTextView.layer.cornerRadius = 5
        self.titleLabel.isHidden = true
        self.descriptionLabel.isHidden = true
        
        doneButton.layer.cornerRadius = 30
        deleteButton.layer.cornerRadius = 30
        doneButton.backgroundColor = .white
        deleteButton.backgroundColor = .white

        titleTextConstraing.constant = 10
        descriptTextConstraing.constant = 10
        
        setShadows()
    }
    
    private func setShadows() {
        doneButton.layer.masksToBounds = false
        doneButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        doneButton.layer.shadowColor = UIColor.black.cgColor
        doneButton.layer.shadowOpacity = 0.23
        doneButton.layer.shadowRadius = 5
        doneButton.layer.shouldRasterize = true
        doneButton.layer.rasterizationScale = UIScreen.main.scale
        
        deleteButton.layer.masksToBounds = false
        deleteButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        deleteButton.layer.shadowColor = UIColor.black.cgColor
        deleteButton.layer.shadowOpacity = 0.23
        deleteButton.layer.shadowRadius = 5
        deleteButton.layer.shouldRasterize = true
        deleteButton.layer.rasterizationScale = UIScreen.main.scale
    }
    
    private func setDoneViewsStyle(with task: Task) {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        self.dateLabel.textColor = .lightGray
        let font = UIFont.systemFont(ofSize: 18)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .strikethroughStyle: NSUnderlineStyle.single.rawValue
        ]
        let attributedStringTitle = NSMutableAttributedString(string: task.title, attributes: attributes)
        
        self.titleTextView.attributedText = attributedStringTitle
        self.titleTextView.textColor = .lightGray
        
        let attributedStringDescription = NSMutableAttributedString(string: task.descript)
        attributedStringDescription.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedStringDescription.length))
        
        self.descriptionTextView.attributedText = attributedStringDescription
        self.descriptionTextView.textColor = .lightGray
        
        self.doneButton.isHidden = true
        self.deleteButton.isHidden = true
        
    }
    
    private func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
      mapView.setRegion(coordinateRegion, animated: true)
    }

    static func create(with viewModel: ViewModelType) -> UIViewController {
        let controller = TaskDetailsView.getInstance() as! TaskDetailsView
        controller.viewModel = viewModel
        return controller
    }
    
}

//MARK: - UITextViewDelegate
extension TaskDetailsView: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        switch textView.tag {
        case 0:
            return updatedText.count <= 100
        case 1:
            return updatedText.count <= 1000
        default:
            return true
        }
    }
}
//MARK: - Keyboard appearing handling
extension TaskDetailsView {
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardHeight != nil {
            return
        }
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}

        self.keyboardHeight = keyboardFrame.height
        self.viewHeightConstraint.constant += keyboardHeight
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.viewHeightConstraint.constant -= keyboardHeight
    }
}
