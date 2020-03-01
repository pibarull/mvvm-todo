//
//  SettingsView.swift
//  MVVM-todo
//
//  Created by Appvelox on 25/02/2020.
//  Copyright © 2020 Ilia Ershov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import UserNotifications

class SettingsView: UIViewController {
    
    typealias ViewModelType = NewTaskViewModel
    
    //MARK: - Outlets
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var timeToNoticeLabel: UILabel!
    @IBOutlet weak var timeToNoticePicker: UIDatePicker!
    
    
    //MARK: - Variables
    private var disposeBag = DisposeBag()
    
    //MARK: - Constatnts

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
        configureNavigationBar()
        setViews()
        
        configure()
    }
    
    //MARK: - Methods
    func configure() {

        solveDatePickerBag()
        
        self.timeToNoticePicker.rx.countDownDuration.withLatestFrom(timeToNoticePicker.rx.date).subscribe { [weak self] _ in
            if let strongSelf = self {
                strongSelf.timeToNoticeLabel.text = "Напомнить за \(strongSelf.timeToNoticePicker.date.getFormattedTime())"
                let (HHToNotice, mmToNotice) = strongSelf.timeToNoticePicker.date.getFormattedTimeInHHmm()
                UserDefaults.standard.set(HHToNotice, forKey: "HHToNotice")
                UserDefaults.standard.set(mmToNotice, forKey: "mmToNotice")

            }
        }.disposed(by: disposeBag)

        self.notificationSwitch.rx.isOn.changed.subscribe { [weak self] _ in
            if let strongSelf = self {
                if !NotificationHandler.shared().notificationEnabled {
                    strongSelf.timeToNoticePicker.isHidden = true
                    strongSelf.timeToNoticeLabel.isHidden = true
                    UserDefaults.standard.set(0, forKey: "HHToNotice")
                    UserDefaults.standard.set(0, forKey: "mmToNotice")
                    
                    NotificationHandler.shared().center.removeAllPendingNotificationRequests()
                } else {
                    strongSelf.timeToNoticePicker.isHidden = false
                    strongSelf.timeToNoticeLabel.isHidden = false
                    UserDefaults.standard.set(1, forKey: "HHToNotice")
                    UserDefaults.standard.set(0, forKey: "mmToNotice")
                    
                }
                NotificationHandler.shared().notificationEnabled = !NotificationHandler.shared().notificationEnabled
                
            }
        }.disposed(by: disposeBag)
    }
    
    private func configureNavigationBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "chevron-left"), style: .plain, target: nil, action: #selector(self.navigationController?.popViewController(animated:)))
        self.navigationItem.leftBarButtonItem?.tintColor = .black
    }

    private func setViews() {
        
        if NotificationHandler.shared().notificationEnabled {
            self.notificationSwitch.isOn = false
            self.timeToNoticePicker.isHidden = true
            self.timeToNoticeLabel.isHidden = true
        } else {
            self.notificationSwitch.isOn = true
            self.timeToNoticePicker.isHidden = false
            self.timeToNoticeLabel.isHidden = false

        }
    
        self.timeToNoticePicker.datePickerMode = .countDownTimer
        self.timeToNoticePicker.minuteInterval = 15
        
        self.timeToNoticeLabel.text = "Напомнить за \(self.timeToNoticePicker.date.getFormattedTime())"
    }
    
    private func solveDatePickerBag() {
        
        let HHToNotice = UserDefaults.standard.integer(forKey: "HHToNotice")
        let mmToNotice = UserDefaults.standard.integer(forKey: "mmToNotice")
        
        
        let dateComp : NSDateComponents = NSDateComponents()
        if HHToNotice != 0 || mmToNotice != 0 {
            dateComp.hour = HHToNotice
            dateComp.minute = mmToNotice
        } else {
            dateComp.hour = 1
            dateComp.minute = 0
        }
        dateComp.timeZone = NSTimeZone.system
        let calendar : NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier(rawValue: NSGregorianCalendar))!
        let date : NSDate = calendar.date(from: dateComp as DateComponents)! as NSDate

        self.timeToNoticePicker.setDate(date as Date, animated: true)
        
    }

    static func create() -> UIViewController {
        let controller = SettingsView.getInstance() as! SettingsView
        return controller
    }

}
