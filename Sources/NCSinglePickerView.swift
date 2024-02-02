//
//  NCSinglePickerView.swift
//  
//
//  Created by who on 2024/2/2.
//

import UIKit

// MARK: - 单选选择模块
protocol NCSinglePickerViewDelegate:NSObjectProtocol {
    func selectedSingle(singleStr: String)
}
class NCSinglePickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // 背景view的颜色
    open var viewbackgroundColor: UIColor = .white {
        didSet {
            backgroundColor = viewbackgroundColor
        }
    }
    open var singlePickerDatas: [String] = ["上午","下午"] {
        didSet {
            singleSelectedData = singlePickerDatas.first!
        }
    } // 单项选择器数据源
    open var singleSelectedData: String = ""

    weak var delegate: NCSinglePickerViewDelegate?

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
            make.edges.equalTo(self)
        }
        
    }

    func relodPickerView() {
        if let index = singlePickerDatas.firstIndex(where: { $0 == singleSelectedData}) {
            pickerView.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return singlePickerDatas.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.text = singlePickerDatas[row]
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        singleSelectedData = singlePickerDatas[row]
        delegate?.selectedSingle(singleStr: singleSelectedData)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
