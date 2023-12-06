//
//  ViewController.swift
//  ZXYCalendarPicker
//
//  Created by who on 2023/12/6.
//

import UIKit
import NCCalendarPicker

class ViewController: UIViewController {

    var calendarDate: UIButton!
    var calendarSingle: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        calendarDate = UIButton()
        calendarDate.setTitle("选择日期+时分", for: .normal)
        calendarDate.setTitleColor(.blue, for: .normal)
        calendarDate.addTarget(self, action: #selector(clickCancelBtn), for: .touchUpInside)
        view.addSubview(calendarDate)
        
        calendarDate.snp.makeConstraints { make in
            make.top.equalTo(200)
            make.centerX.equalTo(self.view)
            make.height.equalTo(40)
        }
        

        calendarSingle = UIButton()
        calendarSingle.setTitle("选择日期+上下午", for: .normal)
        calendarSingle.setTitleColor(.blue, for: .normal)
        calendarSingle.addTarget(self, action: #selector(clickCancelSingleBtn), for: .touchUpInside)
        view.addSubview(calendarSingle)

        calendarSingle.snp.makeConstraints { make in
            make.top.equalTo(calendarDate.snp.bottom).offset(20)
            make.centerX.equalTo(calendarDate)
            make.height.equalTo(40)
        }
        
    }

    @objc func clickCancelBtn() {
        
        let picker = NCCalendarPicker { (date: String, singlePickerStr: String) in
            debugPrint(date)
            debugPrint(singlePickerStr)
            self.calendarDate.setTitle(date, for: .normal)
        }
        picker.pickerStyle = .datePicker
        
        // 上次选择的时间(默认是当前时间)
//        if let selectedDay = timeStrToConvertDate(dateStr: "2023-12-06 10:19", format: "yyyy-MM-dd HH:mm"){
//            picker.selectedDay = selectedDay
//        }
        picker.show()
        
    }
    @objc func clickCancelSingleBtn() {
        let picker = NCCalendarPicker { (date: String, singlePickerStr: String) in
            debugPrint(date)
            debugPrint(singlePickerStr)
            self.calendarSingle.setTitle(date + " " + singlePickerStr, for: .normal)
        }
        picker.pickerStyle = .singlePicker
        picker.singlePickerDatas = ["上午","下午"]
        
        // 上次选择的时间(默认是当前日期 + 上午)
        let datePickerStr = "2023-12-06 上午"
        var dateStr = datePickerStr.replacingOccurrences(of: " 上午", with: "")
        dateStr = dateStr.replacingOccurrences(of: " 下午", with: "")
        picker.selectedDay = timeStrToConvertDate(dateStr: dateStr, format: "yyyy-MM-dd")
        picker.singleSelectedData = datePickerStr.replacingOccurrences(of: dateStr + " ", with: "")
        
        picker.show()
    }
    
    // MARK: - 时间字符串转化给Date
    @objc func timeStrToConvertDate(dateStr: String, format: String) -> Date? {
        let dateString = dateStr // 时间字符串
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format // 设置日期格式与时间字符串相匹配
        if let date = dateFormatter.date(from: dateString) {
            print(date) // 输出：2023-09-21 06:40:47 +0000
            return date
        } else {
            print("日期转换失败")
            return nil
        }
    }


}

