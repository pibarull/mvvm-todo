//
//  UIViewController.swift
//  MVVM-todo
//
//  Created by Илья Ершов on 30/01/2020.
//  Copyright © 2020 Ilia Ershov. All rights reserved.
//

import UIKit

extension UIViewController {

    /// Returns the initial view controller on a storyboard
    static func getInstance() -> UIViewController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self))
    }
    
    internal func hideKeyboardOnTap(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tap.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tap);
        //self.hideKeyboard()
    }

    @objc private func hideKeyboard(){
        self.view.endEditing(true);
    }
}
