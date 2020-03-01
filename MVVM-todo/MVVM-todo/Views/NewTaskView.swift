//
//  NewTaskView.swift
//  MVVM-todo
//
//  Created by Илья Ершов on 11/02/2020.
//  Copyright © 2020 Ilia Ershov. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import RxCocoa
import CoreLocation

class NewTaskView: UIViewController {
    
    typealias ViewModelType = NewTaskViewModel
    
    //MARK: - Outlets
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var deadlineSwitch: UISwitch!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Variables
    var viewModel: ViewModelType!
    private var keyboardHeight: CGFloat!
    private var deadlineEnabled: Bool = false
    private var disposeBag = DisposeBag()
    
    //MARK: - Constatnts
    let locationManager = CLLocationManager()

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardOnTap()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        titleTextView.delegate = self
        descriptionTextView.delegate = self
        
        configureNavigationBar()
        setViews()
        
        locationHadling()
        
        configure(with: viewModel)
    }
    
    //MARK: - Methods
    func configure(with viewModel: ViewModelType) {
        
        self.navigationItem.rightBarButtonItem?.rx.tap.subscribe({ [weak self] _ in
            if let strongSelf = self {
                if !strongSelf.titleTextView.text.isEmpty && !strongSelf.descriptionTextView.text.isEmpty {
                    let deadline = strongSelf.datePicker.date
                    let task = Task(title: strongSelf.titleTextView.text, descript: strongSelf.descriptionTextView.text, deadline: deadline, hasDeadline: strongSelf.deadlineEnabled )
                    viewModel.input.savePressed.onNext(task)
                } else {
                    System.showSystemAlert(vc: strongSelf,
                                           title: "Все поля должны быть заполнены",
                                           message: nil,
                                           actionOneTitle: "Ок",
                                           actionOneStyle: .default)
                }
            }
            }).disposed(by: disposeBag)
        
        viewModel.output.shouldDismiss.subscribe(onNext: { [unowned self] _ in
            self.navigationController?.popViewController(animated: true)
        })
        
        self.deadlineSwitch.rx.value.subscribe { [weak self] _ in
            if let strongSelf = self {
                if strongSelf.deadlineEnabled {
                    strongSelf.deadlineLabel.isHidden = true
                    strongSelf.datePicker.isHidden = true

                } else {
                    strongSelf.deadlineLabel.isHidden = false
                    strongSelf.datePicker.isHidden = false
                }
                strongSelf.deadlineEnabled = !strongSelf.deadlineEnabled
                
            }
        }.disposed(by: disposeBag)
    }
    
    private func configureNavigationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: nil)
    }
    
    private func setViews() {
        self.descriptionTextView.layer.cornerRadius = 5
        self.titleTextView.layer.cornerRadius = 5
        self.titleTextView.backgroundColor = UIColor(named: "enterTextColor")
        self.descriptionTextView.backgroundColor = UIColor(named: "enterTextColor")
    }
    
    func locationHadling() {
        self.locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let controller = NewTaskView.getInstance() as! NewTaskView
        controller.viewModel = viewModel
        return controller
    }

}

//MARK: - Keyboard appearing handling
extension NewTaskView {
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

//MARK: - UITextViewDelegate
extension NewTaskView: UITextViewDelegate {

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

//MARK: - CLLocationManagerDelegate
extension NewTaskView: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        viewModel.input.setLocation.onNext((locValue.latitude, locValue.longitude))
    }
}
