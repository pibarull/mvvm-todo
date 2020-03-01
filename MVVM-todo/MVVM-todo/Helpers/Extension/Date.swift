//
//  Date.swift
//  MVVM-todo
//
//  Created by Илья Ершов on 30/01/2020.
//  Copyright © 2020 Ilia Ershov. All rights reserved.
//

import Foundation

extension Date {
    func getFormattedDate() -> String {
        var formatedDate: String?
    
        let myFormatter = DateFormatter()
        myFormatter.dateFormat = "HH:mm dd MMMM yyyy"
        myFormatter.locale = Locale(identifier: "ru_RU")
        formatedDate = myFormatter.string(from: self)
        
        return formatedDate ?? "DATE NOT RECOGNIZED"
    }
    
    func getFormattedTime() -> String {
        var formatedDate: String?
        var formatedHours: String?
    
        let myFormatter = DateFormatter()
        let myFormatterHH = DateFormatter()
        myFormatterHH.dateFormat = "HH"
        myFormatterHH.locale = Locale(identifier: "ru_RU")
        formatedHours = myFormatterHH.string(from: self)
        var hours: String = ""
        if let HH = Int(formatedHours!) {
            switch HH {
            case 1, 21:
                hours = "час"
                
            case 2...4, 22...24:
                hours = "часа"
            case 0, 5...20:
                hours = "часов"
            default:
                break
            }
        }
        myFormatter.dateFormat = "HH \(hours) mm минут"
        myFormatter.locale = Locale(identifier: "ru_RU")
        formatedDate = myFormatter.string(from: self)
        
        return formatedDate ?? "DATE NOT RECOGNIZED"
    }
    
    func getFormattedTimeInHHmm() -> (Int, Int) {
        var formatedMinutes: String?
        var formatedHours: String?
    
        let myFormattermm = DateFormatter()
        let myFormatterHH = DateFormatter()
        myFormatterHH.dateFormat = "HH"
        myFormattermm.dateFormat = "mm"
        myFormatterHH.locale = Locale(identifier: "ru_RU")
        myFormattermm.locale = Locale(identifier: "ru_RU")
        formatedHours = myFormatterHH.string(from: self)
        formatedMinutes = myFormattermm.string(from: self)
        let HH = Int(formatedHours!)!
        let mm = Int(formatedMinutes!)!
        
        
        return (HH, mm)
    }
    
    func getFormattedTimeInYYYYMMdd() -> (Int, Int, Int) {
        var formatedYear: String?
        var formatedMonth: String?
        var formatedDay: String?
    
        let myFormatterYYYY = DateFormatter()
        let myFormatterMM = DateFormatter()
        let myFormatterdd = DateFormatter()
        myFormatterYYYY.dateFormat = "YYYY"
        myFormatterMM.dateFormat = "MM"
        myFormatterdd.dateFormat = "dd"
        myFormatterYYYY.locale = Locale(identifier: "ru_RU")
        myFormatterMM.locale = Locale(identifier: "ru_RU")
        myFormatterdd.locale = Locale(identifier: "ru_RU")
        formatedYear = myFormatterYYYY.string(from: self)
        formatedMonth = myFormatterMM.string(from: self)
        formatedDay = myFormatterdd.string(from: self)
        let YYYY = Int(formatedYear!)!
        let MM = Int(formatedMonth!)!
        let dd = Int(formatedDay!)!
        
        return (YYYY, MM, dd)
    }
}
