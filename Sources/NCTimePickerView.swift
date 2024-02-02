//
//  NCTimePickerView.swift
//
//
//  Created by who on 2024/2/2.
//

import UIKit

// MARK: - 时间选择模块
protocol NCTimePickerViewViewDelegate:NSObjectProtocol {
    func selectedTime(time: String)
}
class NCTimePickerView: UIView {
    
    // 背景view的颜色
    open var viewbackgroundColor: UIColor = .white {
        didSet {
            backgroundColor = viewbackgroundColor
        }
    }
    open var selectedDay: Date! = Date() { // 选择的时间
        didSet {
            datePicker.setDate(selectedDay, animated: true)
        }
    } // 单项选择器数据源
    
    var datePicker: UIDatePicker!
    weak var delegate: NCTimePickerViewViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = viewbackgroundColor
        
        datePicker = UIDatePicker(frame: frame)
//        datePicker.locale = Locale(identifier: "zh_CN")
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker.datePickerMode = .time
        datePicker.addTarget(self, action: #selector(datePickerValueChange(_:)), for: UIControl.Event.valueChanged)
        addSubview(datePicker)
                
        datePicker.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    @objc func datePickerValueChange(_ datePicker: UIDatePicker) {
        let date = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: date)
        delegate?.selectedTime(time: time)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
