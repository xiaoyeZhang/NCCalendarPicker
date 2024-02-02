//
//  ViewController.swift
//  ZXYCalendarPicker
//
//  Created by who on 2023/12/6.
//

import UIKit
import NCCalendarPicker

class ViewController: UIViewController {

    var calendarDateRange: UIButton!
    var calendarCurrDate: UIButton!
    var calendarDate: UIButton!
    var calendarSingle: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        calendarDateRange = UIButton()
        calendarDateRange.setTitle("选择日期范围", for: .normal)
        calendarDateRange.setTitleColor(.blue, for: .normal)
        calendarDateRange.addTarget(self, action: #selector(clickDateCancelBtn), for: .touchUpInside)
        view.addSubview(calendarDateRange)
        
        calendarDateRange.snp.makeConstraints { make in
            make.top.equalTo(200)
            make.centerX.equalTo(self.view)
            make.height.equalTo(40)
        }
        
        calendarCurrDate = UIButton()
        calendarCurrDate.setTitle("选择日期+时分秒", for: .normal)
        calendarCurrDate.setTitleColor(.blue, for: .normal)
        calendarCurrDate.addTarget(self, action: #selector(clickTimeBtn), for: .touchUpInside)
        view.addSubview(calendarCurrDate)
        
        calendarCurrDate.snp.makeConstraints { make in
            make.top.equalTo(calendarDateRange.snp.bottom).offset(20)
            make.centerX.equalTo(self.view)
            make.height.equalTo(40)
        }
        
        
        calendarDate = UIButton()
        calendarDate.setTitle("选择日期+时分", for: .normal)
        calendarDate.setTitleColor(.blue, for: .normal)
        calendarDate.addTarget(self, action: #selector(clickCancelBtn), for: .touchUpInside)
        view.addSubview(calendarDate)
        
        calendarDate.snp.makeConstraints { make in
            make.top.equalTo(calendarCurrDate.snp.bottom).offset(20)
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
    
    @objc func clickDateCancelBtn() {
        let picker = NCCalendarPicker { (date: String, singlePickerStr: String, dateRange: NCDateRangeModel) in
            debugPrint(date)
            debugPrint(singlePickerStr)
            debugPrint(dateRange.startDate ?? Date())
            let currentStartDate = self.formatterDate(curDate: dateRange.startDate ?? Date(), formatter: "YYYY-MM-dd")
            let currentEndDate = self.formatterDate(curDate: dateRange.endDate ?? Date(), formatter: "YYYY-MM-dd")
            self.calendarDateRange.setTitle(currentStartDate + " ~ " + currentEndDate, for: .normal)
            
        }
        picker.showDateBtnShadowColor = true
        picker.cancelBtnIcon = UIImage(systemName: "xmark")
        picker.weekTitleColor = UIColor(red: 23/255.0, green: 26/255.0, blue: 29/255.0, alpha: 0.6)
        picker.currentDisDayColor = UIColor(red: 8/255.0, green: 118/255.0, blue: 251/255.0, alpha: 0.1)
        picker.currentDayTextColor = UIColor(red: 8/255.0, green: 118/255.0, blue: 251/255.0, alpha: 1.0)
        picker.dateAndtimeViewHeight = 28
        picker.pickerStyle = .dateRange
        if let minimumDate = timeStrToConvertDate(dateStr: "2024-01-06", format: "yyyy-MM-dd") {
            picker.minimumDate = minimumDate
        }
        if let maximumDate = timeStrToConvertDate(dateStr: "2024-01-21", format: "yyyy-MM-dd") {
            picker.maximumDate = maximumDate
        }
        // 上次选择的时间(默认是当前时间)
//        if let selectedDay = timeStrToConvertDate(dateStr: "2023-12-06 10:19", format: "yyyy-MM-dd HH:mm"){
//            picker.selectedDay = selectedDay
//        }
        picker.show()
    }
    
    @objc func clickTimeBtn() {
        
        let picker = NCCalendarPicker { (date: String, singlePickerStr: String, dateRange: NCDateRangeModel) in
            debugPrint(date)
            debugPrint(singlePickerStr)
            debugPrint(dateRange.startDate ?? Date())
            self.calendarCurrDate.setTitle(date, for: .normal)
        }
        picker.showDateBtnShadowColor = true
        picker.dateAndtimeViewBgColor = UIColor(red: 241/255.0, green: 242/255.0, blue: 243/255.0, alpha: 1.0)
        picker.dateBtnBgColor = .white
        picker.cancelBtnIcon = UIImage(systemName: "xmark")
        picker.weekTitleColor = UIColor(red: 23/255.0, green: 26/255.0, blue: 29/255.0, alpha: 0.6)
        picker.currentDisDayColor = UIColor(red: 8/255.0, green: 118/255.0, blue: 251/255.0, alpha: 0.1)
        picker.currentDayTextColor = UIColor(red: 8/255.0, green: 118/255.0, blue: 251/255.0, alpha: 1.0)
        picker.dateAndtimeViewHeight = 28
        picker.pickerStyle = .dateTimeAndSecond
        // 上次选择的时间(默认是当前时间)
        if let selectedDay = timeStrToConvertDate(dateStr: self.calendarCurrDate.titleLabel!.text!, format: "yyyy-MM-dd HH:mm:ss"){
            picker.selectedDay = selectedDay
        }
        picker.show()
        
    }
    
    @objc func clickCancelBtn() {
        
        let picker = NCCalendarPicker { (date: String, singlePickerStr: String, dateRange: NCDateRangeModel) in
            debugPrint(date)
            debugPrint(singlePickerStr)
            debugPrint(dateRange.startDate ?? Date())
            self.calendarDate.setTitle(date, for: .normal)
        }
        picker.showDateBtnShadowColor = true
        picker.dateAndtimeViewBgColor = UIColor(red: 241/255.0, green: 242/255.0, blue: 243/255.0, alpha: 1.0)
        picker.dateBtnBgColor = .white
        picker.cancelBtnIcon = UIImage(systemName: "xmark")
        picker.weekTitleColor = UIColor(red: 23/255.0, green: 26/255.0, blue: 29/255.0, alpha: 0.6)
        picker.currentDisDayColor = UIColor(red: 8/255.0, green: 118/255.0, blue: 251/255.0, alpha: 0.1)
        picker.currentDayTextColor = UIColor(red: 8/255.0, green: 118/255.0, blue: 251/255.0, alpha: 1.0)
        picker.dateAndtimeViewHeight = 28
        picker.pickerStyle = .datePicker
        // 上次选择的时间(默认是当前时间)
        if let selectedDay = timeStrToConvertDate(dateStr: self.calendarDate.titleLabel!.text!, format: "yyyy-MM-dd HH:mm"){
            picker.selectedDay = selectedDay
        }
        picker.show()
        
    }
    @objc func clickCancelSingleBtn() {
        let picker = NCCalendarPicker { (date: String, singlePickerStr: String, dateRange: NCDateRangeModel?) in
            debugPrint(date)
            debugPrint(singlePickerStr)
            self.calendarSingle.setTitle(date + " " + singlePickerStr, for: .normal)
        }
        picker.currentDisDayColor = UIColor(red: 8/255.0, green: 118/255.0, blue: 251/255.0, alpha: 0.1)
        picker.currentDayTextColor = UIColor(red: 8/255.0, green: 118/255.0, blue: 251/255.0, alpha: 1.0)
        picker.pickerStyle = .singlePicker
        picker.singlePickerDatas = ["上午","下午"]
        
        // 上次选择的时间(默认是当前日期 + 上午)
        let datePickerStr = self.calendarSingle.titleLabel!.text!
        var dateStr = datePickerStr.replacingOccurrences(of: " 上午", with: "")
        dateStr = dateStr.replacingOccurrences(of: " 下午", with: "")
        if let selectedDay = timeStrToConvertDate(dateStr: dateStr, format: "yyyy-MM-dd") {
            picker.selectedDay = selectedDay
            picker.singleSelectedData = datePickerStr.replacingOccurrences(of: dateStr + " ", with: "")
        }
        
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


    func formatterDate(curDate: Date, formatter: String) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = formatter
        let dateString = dateformatter.string(from: curDate)
        return dateString
    }
    
}

