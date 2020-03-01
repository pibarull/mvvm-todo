//
//  System.swift
//  MVVM-todo
//
//  Created by Илья Ершов on 11/02/2020.
//  Copyright © 2020 Ilia Ershov. All rights reserved.
//

import UIKit

struct System {
    
    static func showSystemAlert(vc: UIViewController, title: String?, message: String?, actionOneTitle: String = "Понятно", actionOneStyle: UIAlertAction.Style = .cancel, actionOneHandler: ((UIAlertAction)->())? = nil, actionTwoTitle: String? = nil, actionTwoStyle: UIAlertAction.Style? = nil,actionTwoHandler: ((UIAlertAction)->())? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOne = UIAlertAction(title: actionOneTitle, style: actionOneStyle, handler: actionOneHandler)
        alert.addAction(actionOne)
        if let actionTwoTitle = actionTwoTitle {
            let actionTwo = UIAlertAction(title: actionTwoTitle, style: actionTwoStyle ?? .cancel, handler: actionTwoHandler)
            alert.addAction(actionTwo)
        }
        vc.present(alert, animated: true, completion: nil)
    }
}
