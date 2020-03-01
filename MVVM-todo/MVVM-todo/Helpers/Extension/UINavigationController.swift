//
//  UINavigationController.swift
//  MVVM-todo
//
//  Created by Илья Ершов on 30/01/2020.
//  Copyright © 2020 Ilia Ershov. All rights reserved.
//

import Foundation

import UIKit

extension UINavigationController {
    
    func showVC(target: UIViewController, sender: UIViewController) {
        
        if let nav = sender as? UINavigationController {
            //push root controller on navigation stack
            nav.pushViewController(target, animated: false)
            return
        }
        
        if let nav = sender.navigationController {
            //add controller to navigation stack
            nav.pushViewController(target, animated: true)
        } else {
            //present modally
            sender.present(target, animated: true, completion: nil)
        }
    }
    
}
