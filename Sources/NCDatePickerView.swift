//
//  NCDatePickerView.swift
//  
//
//  Created by who on 2024/2/2.
//

import UIKit

// MARK: - 时分秒模块
protocol NCDateTimeAndSecondPickerViewDelegate:NSObjectProtocol {
    func selectedTimeAndSecond(timeStr: String)
}
class NCDateTimeAndSecondPickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // 背景view的颜色
    open var viewbackgroundColor: UIColor = .white {
        didSet {
            backgroundColor = viewbackgroundColor
        }
    }
    open var selectedDay: Date! = Date() { // 选择的时间
        didSet {
            relodPickerView()
        }
    } // 单项选择器数据源
    
    var Hour: [Int] = Array(0...23)
    var minute: [Int] = Array(0...59)
    var second: [Int] = Array(0...59)
    
    weak var delegate: NCDateTimeAndSecondPickerViewDelegate?

    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.backgroundColor = .clear
        pickerView.showsSelectionIndicator = true
        pickerView.delegate = self
        pickerView.dataSource = self

        return pickerView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = viewbackgroundColor

        self.addSubview(self.pickerView)
        pickerView.snp.makeConstraints { make in
            make.top.bottom.equalTo(self)
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
        }
        
    }

    func relodPickerView() {
        
        if let index = Hour.firstIndex(where: { $0 == selectedDay.hour}) {
            pickerView.selectRow(index, inComponent: 0, animated: true)
        }
        if let index = minute.firstIndex(where: { $0 == selectedDay.minute}) {
            pickerView.selectRow(index, inComponent: 1, animated: true)
        }
        if let index = second.firstIndex(where: { $0 == selectedDay.second}) {
            pickerView.selectRow(index, inComponent: 2, animated: true)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var pickNum = 0
        switch component {
        case 0:
            pickNum = Hour.count
        case 1:
            pickNum = minute.count
        case 2:
            pickNum = second.count
        default:
            break
        }
        
        return pickNum
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        var pickerDatas: [Int] = []
        switch component {
        case 0:
            pickerDatas = Hour
        case 1:
            pickerDatas = minute
        case 2:
            pickerDatas = second
        default:
            break
        }
        label.text = pickerDatas[row] < 10 ? "0\(pickerDatas[row])" : String(pickerDatas[row])
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        let selectedValues = getSelectedValues(pickerView)
        let timeStr = selectedValues.joined(separator: ":")
        
        delegate?.selectedTimeAndSecond(timeStr: timeStr)
    }
    
    func getSelectedValues(_ pickerView: UIPickerView) -> [String] {
       var selectedValues = [String]()
       for component in 0..<pickerView.numberOfComponents {
           let selectedRow = pickerView.selectedRow(inComponent: component)
           switch component {
           case 0:
               let selectedValue = Hour[selectedRow]
               selectedValues.append(selectedValue < 10 ? "0\(selectedValue)" : String(selectedValue))
           case 1:
               let selectedValue = minute[selectedRow]
               selectedValues.append(selectedValue < 10 ? "0\(selectedValue)" : String(selectedValue))
           case 2:
               let selectedValue = second[selectedRow]
               selectedValues.append(selectedValue < 10 ? "0\(selectedValue)" : String(selectedValue))
           default:
               break
           }
       }
       return selectedValues
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
