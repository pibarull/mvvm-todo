//
//  TaskTableViewCell.swift
//  MVVM-todo
//
//  Created by Илья Ершов on 30/01/2020.
//  Copyright © 2020 Ilia Ershov. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var taskStatus: String!
    
    var task: Task? {
        didSet {
            guard let task = task else {
                return
            }
            self.taskStatus = task.taskStatus
            dateLabel.text = task.deadline.getFormattedDate()
            
            let attributedString = NSMutableAttributedString(string: task.title)
            if task.taskStatus == Task.Status.done.rawValue {
                setDoneStyle(attributedString)
            } else {
                setUndoneStyle(attributedString)
            }

//            if !task.hasDeadline {
//                self.dateLabel.isHidden = true
//            }
            
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setCellStyle()
    }
    
    // MARK: - Functions
    
    func setCellStyle() {
        titleLabel?.numberOfLines = 2
        
//        if self.taskStatus == Task.Status.expired.rawValue {
//            dateLabel.textColor = .red
//        } else if self.taskStatus == Task.Status.undone.rawValue {
//            //TODO: - add yelow color
//            dateLabel.textColor = .green
//        }
        
        let screenWight = UIScreen.main.bounds.width
        let mainBackground = UIView(frame: CGRect(x: self.frame.minX + 2, y: self.frame.minY-28, width: screenWight - 22, height: self.frame.maxY - 36))
        
        let shadowLayer = UIView(frame: CGRect(x: self.frame.minX + 10, y: self.frame.minY-25, width: screenWight - 20, height: self.frame.maxY - 35))
        
        mainBackground.addSubview(self.contentView)
        shadowLayer.addSubview(mainBackground)
        self.addSubview(shadowLayer)
        
        
        mainBackground.layer.cornerRadius = 10
        mainBackground.layer.masksToBounds = true
        mainBackground.backgroundColor = .white

        shadowLayer.layer.masksToBounds = false
        shadowLayer.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowLayer.layer.shadowColor = UIColor.black.cgColor
        shadowLayer.layer.shadowOpacity = 0.23
        shadowLayer.layer.shadowRadius = 4
        
        shadowLayer.layer.shadowPath = UIBezierPath(roundedRect: shadowLayer.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        shadowLayer.layer.shouldRasterize = true
        shadowLayer.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func setDoneStyle(_ attributedString: NSMutableAttributedString) {
        titleLabel.textColor = .lightGray
        attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
        titleLabel.attributedText = attributedString
    }
    
    func setUndoneStyle(_ attributedString: NSMutableAttributedString) {
//        titleLabel.textColor = .black
        
        attributedString.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSRange(location: 0, length: attributedString.length))
        titleLabel.attributedText = attributedString
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
