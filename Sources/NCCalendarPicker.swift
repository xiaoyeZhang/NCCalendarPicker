//
//  NCCalendarPicker.swift
//  ZXYCalendarPickerDemo
//
//  Created by who on 2023/10/11.
//

import UIKit
import SnapKit

public let kScreen_width: CGFloat = UIScreen.main.bounds.size.width
public let kScreen_height:CGFloat = UIScreen.main.bounds.size.height

private let keyWindow = UIApplication.shared.keyWindow
private let calendarItemMargin: CGFloat = 6 * 8
private let calendarItemWH: CGFloat = (kScreen_width - 20 - calendarItemMargin) / 7
private let headViewH: CGFloat = 52
private let calendarViewTop: CGFloat = 5
private var baseViewHeight = headViewH + calendarViewTop + 30 + 6 * calendarItemWH + calendarItemMargin + UIDevice.vg_safeDistanceBottom()

/// 日期选择器枚举
public enum NCCalendarMode: Int {
    case datePicker // 日期-时分选择器
    case dateTimeAndSecond // 日期-时分秒选择器
    case singlePicker // 单项选择器
    case dateRange // 时间范围选择器
}

//MARK: - 时间范围
public struct NCDateRangeModel {
    public var startDate: Date? = nil
    public var endDate: Date? = nil
}

//MARK: - 日期对象
class NCCurrentDateModel: NSObject {
    var daysInThisMonth: Int = 0
    var firstWeekDay: Int = 0
    var currentMonth: Int = 0
    var currentYear: Int = 0
    var lastMonthDate: Date = Date()
    var lastMonth: Int = 0
    var daysInLastMonth: Int = 0
    var nextMonthDate: Date = Date()
    var nextMonth: Int = 0
    var daysInNextMonth: Int = 0
    
    init(daysInThisMonth: Int, firstWeekDay: Int, currentMonth: Int, currentYear: Int, lastMonthDate: Date, nextMonthDate: Date) {
        self.daysInThisMonth = daysInThisMonth
        self.firstWeekDay = firstWeekDay
        self.currentMonth = currentMonth
        self.currentYear = currentYear
        self.lastMonthDate = lastMonthDate
        self.lastMonth = self.lastMonthDate.month
        self.daysInLastMonth = self.lastMonthDate.totalDaysInThisMonth
        self.nextMonthDate = nextMonthDate
        self.nextMonth = self.nextMonthDate.month
        self.daysInNextMonth = self.nextMonthDate.totalDaysInThisMonth
    }
}

public class NCCalendarPicker: UIView, UIGestureRecognizerDelegate, CalendarViewDelegate, NCTimePickerViewViewDelegate, NCSinglePickerViewDelegate, NCDateTimeAndSecondPickerViewDelegate {
    public typealias DidSelectedDate = (_ date: String, _ singlePickerStr: String, _ dateRange: NCDateRangeModel) -> Void

    public var dateRangeModel: NCDateRangeModel = NCDateRangeModel()

    open var singlePickerDatas: [String] = ["上午","下午"] {
        didSet {
            singleSelectedData = singlePickerDatas.first!
        }
    } // 单项选择器数据源
    open var singleSelectedData: String = ""
    open var selectedDay: Date! = Date()  // 选择的时间
    private var baseView: UIView!
    private var headView: UIView!
    private var headBottomLine: UIView!
    private var dateAndtimeView: UIView!
    private var cancelBtn: UIButton!
    private var okBtn: UIButton!
    private var dateBtn: UIButton!
    private var timeBtn: UIButton!
    private var dateLabel: UILabel!
    private var currentDate: String!
    private var currentTime: String!
    private var selectedBack: DidSelectedDate?
    
    private lazy var calendarView: CalendarView! = {
        let calendarView = CalendarView(frame: CGRect(x: 0, y: headViewH + calendarViewTop, width: kScreen_width, height: baseViewHeight - headViewH - calendarViewTop - UIDevice.vg_safeDistanceBottom()))
        calendarView.viewbackgroundColor = calendarViewBaseViewColor
        calendarView.delegate = self
        return calendarView
    }()
    
    private lazy var timePickerView: NCTimePickerView! = {
        let timePickerView = NCTimePickerView(frame: calendarView.frame)
        timePickerView.viewbackgroundColor = timePickerBaseViewColor
        timePickerView.frame.origin.x = baseView.frame.size.width
        timePickerView.delegate = self
        return timePickerView
    }()
    
    private lazy var singlePickerView: NCSinglePickerView! = {
        let singlePickerView = NCSinglePickerView(frame: calendarView.frame)
        singlePickerView.frame.origin.x = baseView.frame.size.width
        singlePickerView.viewbackgroundColor = singleBaseViewColor
        singlePickerView.singlePickerDatas = singlePickerDatas
        singlePickerView.singleSelectedData = singleSelectedData
        singlePickerView.delegate = self
        return singlePickerView
    }()
    
    private lazy var dateTimePickerView: NCDateTimeAndSecondPickerView! = {
        let dateTimePickerView = NCDateTimeAndSecondPickerView(frame: calendarView.frame)
        dateTimePickerView.viewbackgroundColor = timePickerBaseViewColor
        dateTimePickerView.frame.origin.x = baseView.frame.size.width
        dateTimePickerView.delegate = self
        return dateTimePickerView
    }()
    
    // 是否需要选择时间
    open var isAllowSelectTime: Bool! = true {
        didSet {
            if isAllowSelectTime == true {
                dateBtn.isUserInteractionEnabled = true
                timeBtn.isHidden = false
            } else {
                dateBtn.isUserInteractionEnabled = false
                timeBtn.isHidden = true
                dateBtn.snp.makeConstraints { make in
                    make.centerX.equalTo(dateAndtimeView)
                }
            }
        }
    }
    // 背景view的颜色
    open var baseViewColor: UIColor = .white {
        didSet {
            baseView.backgroundColor = baseViewColor
        }
    }
    // 顶部视图底部线的颜色
    open var headBottomLineBgColor: UIColor = UIColor.hex(hex: 0xF4F4F4) {
        didSet {
            headBottomLine.backgroundColor = headBottomLineBgColor
        }
    }
    
    // timePickerView的背景颜色
    open var timePickerBaseViewColor: UIColor = .white {
        didSet {
            timePickerView.viewbackgroundColor = timePickerBaseViewColor
        }
    }
    // singlePickerView的背景颜色
    open var singleBaseViewColor: UIColor = .white {
        didSet {
            singlePickerView.viewbackgroundColor = singleBaseViewColor
        }
    }
    
    // 取消按钮的文字颜色
    open var cancelBtnTextColor: UIColor = UIColor.hex(hex: 0x1890FF) {
        didSet {
            cancelBtn.setTitleColor(cancelBtnTextColor, for: .normal)
        }
    }
    
    // 确定按钮的文字颜色
    open var okBtnTextColor: UIColor = UIColor.hex(hex: 0x1890FF) {
        didSet {
            okBtn.setTitleColor(okBtnTextColor, for: .normal)
        }
    }
    
    // 顶部日期/时间按钮的父视图的高度
    open var dateAndtimeViewHeight: CGFloat = 0.0 {
        didSet {
            if dateAndtimeViewHeight > 0 {
                dateAndtimeView.snp.makeConstraints { make in
                    make.height.equalTo(dateAndtimeViewHeight)
                }
            }
        }
    }
    
    // 顶部日期/时间按钮的父视图的背景颜色
    open var dateAndtimeViewBgColor: UIColor = UIColor.clear {
        didSet {
            if showDateBtnShadowColor {
                dateAndtimeView.layer.cornerRadius = 4
                dateAndtimeView.backgroundColor = dateAndtimeViewBgColor
            }
        }
    }
    
    // 是否显示日期/时间按钮的阴影 默认不显示阴影
    open var showDateBtnShadowColor: Bool! = false {
        didSet {
            if showDateBtnShadowColor {
                dateAndtimeView.backgroundColor = dateAndtimeViewBgColor
                dateBtn.layer.shadowColor = dateBtnShadowColor.cgColor
                dateBtn.backgroundColor = dateBtnBgColor
            }
        }
    }
    
    // 顶部日期/时间按钮的背景颜色
    open var dateBtnBgColor: UIColor = UIColor.clear {
        didSet {
            dateBtn.backgroundColor = dateBtnBgColor
        }
    }
    
    // 顶部日期/时间按钮的父视图的高度
    open var dateBtnShadowColor: UIColor = UIColor.hex(hex: 0x000000, alpha: 0.16) {
        didSet {
            if showDateBtnShadowColor {
                dateBtn.layer.shadowColor = dateBtnShadowColor.cgColor
            }
        }
    }
    
    // 顶部切换日期/时间按钮的选中文字颜色
    open var dateBtnSelectedColor: UIColor = UIColor.hex(hex: 0x313439) {
        didSet {
            dateBtn.setTitleColor(dateBtnSelectedColor, for: UIControl.State.selected)
            timeBtn.setTitleColor(dateBtnSelectedColor, for: UIControl.State.selected)

        }
    }
    
    // 顶部切换日期/时间按钮的未选中文字颜色
    open var dateBtnNormalColor: UIColor = UIColor.hex(hex: 0x9A9B9F) {
        didSet {
            dateBtn.setTitleColor(dateBtnNormalColor, for: UIControl.State.normal)
            timeBtn.setTitleColor(dateBtnNormalColor, for: UIControl.State.normal)
        }
    }

    //MARK: calendarView的颜色控制
    // timePickerView的背景颜色
    open var calendarViewBaseViewColor: UIColor = .white {
        didSet {
            calendarView.viewbackgroundColor = calendarViewBaseViewColor
        }
    }
    // 周标题的文字颜色
    open var weekTitleColor: UIColor = .black {
        didSet {
            calendarView.weekTitleColor = weekTitleColor
        }
    }
    // 不是当前月份的日期的文字颜色
    open var dayColor: UIColor = UIColor.hex(hex: 0xE0E2E4) {
        didSet {
            calendarView.dayColor = dayColor
            calendarView.collectionView.reloadData()
        }
    }
    // 是当前月份的日期的文字颜色
    open var currentMonthTextColor: UIColor = UIColor.hex(hex: 0x313439) {
        didSet {
            calendarView.currentMonthTextColor = currentMonthTextColor
            calendarView.collectionView.reloadData()
        }
    }
    // 取消按钮的文字
    open var cancelBtnText: String = "取消" {
        didSet {
            cancelBtn.setTitle(cancelBtnText, for: UIControl.State.normal)
        }
    }
    // 确定按钮的文字
    open var okBtnText: String = "确定" {
        didSet {
            okBtn.setTitle(okBtnText, for: UIControl.State.normal)
        }
    }
    
    // 取消按钮的图标
    open var cancelBtnIcon: UIImage? = nil {
        didSet {
            if cancelBtnIcon != nil {
                cancelBtn.setTitle("", for: .normal)
                cancelBtn.setImage(cancelBtnIcon, for: .normal)
            }
        }
    }
    // 确定按钮的图标
    open var okBtnIcon: UIImage? = nil {
        didSet {
            if okBtnIcon != nil {
                okBtn.setTitle("", for: .normal)
                okBtn.setImage(okBtnIcon, for: .normal)
            }
        }
    }
    
    // 选中的是当天的背景颜色
    open var currentDayColor: UIColor = UIColor.hex(hex: 0x2395FF) {
        didSet {
            calendarView.currentDayColor = currentDayColor
            calendarView.collectionView.reloadData()
        }
    }
    // 选中的不是当天的背景颜色
    open var currentDisDayColor: UIColor = UIColor.hex(hex: 0xEEEEEE) {
        didSet {
            calendarView.currentDisDayColor = currentDisDayColor
            calendarView.collectionView.reloadData()
        }
    }
    // 每个月的1号的文字颜色
    open var firstDayColor: UIColor = UIColor.hex(hex: 0x1890FF) {
        didSet {
            calendarView.firstDayColor = firstDayColor
            calendarView.collectionView.reloadData()
        }
    }
    
    // 今天的日期文字颜色
    open var currentDayTextColor: UIColor = UIColor.hex(hex: 0x313439) {
        didSet {
            calendarView.currentDayTextColor = currentDayTextColor
            calendarView.collectionView.reloadData()
        }
    }
    
    // specify min/max date range. default is nil. When min > max, the values are ignored.
    // default is nil
    open var minimumDate: Date? = nil {
        didSet {
            calendarView.minimumDate = minimumDate
        }
    }
    
    open var maximumDate: Date? = nil {
        didSet {
            calendarView.maximumDate = maximumDate
        }
    }
    open var pickerStyle: NCCalendarMode = .dateRange ///< 选择样式 默认 datePicker

    public init(selectedDate: @escaping DidSelectedDate) {
        super.init(frame: UIScreen.main.bounds)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(close))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
        backgroundColor = .clear
        selectedBack = selectedDate
        baseView = UIView()
        baseView.transform = CGAffineTransform.identity
        baseView.backgroundColor = baseViewColor
        self.addSubview(baseView)
        
        // 在此处设置顶部圆角
        let cornerRadius: CGFloat = 20.0
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        baseView.layer.mask = maskLayer
        
        baseView.snp.makeConstraints { make in
            make.left.right.equalTo(self)
            make.top.equalTo(kScreen_height)
            make.height.equalTo(baseViewHeight)
        }
        
        headView = UIView()
        baseView.addSubview(headView)
        headView.snp.makeConstraints { make in
            make.top.left.right.equalTo(baseView)
            make.height.equalTo(headViewH)
        }
        
        headBottomLine = UIView()
        headBottomLine.backgroundColor = headBottomLineBgColor
        headView.addSubview(headBottomLine)
        headBottomLine.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(headView)
            make.height.equalTo(0.5)
        }
        
        cancelBtn = UIButton(type: UIButton.ButtonType.system)
        cancelBtn.setTitle(cancelBtnText, for: UIControl.State.normal)
        cancelBtn.setTitleColor(cancelBtnTextColor, for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: UIDevice.currentDeviceType() == "iPad" ? 17 : 15)
        cancelBtn.addTarget(self, action: #selector(clickCancelBtn), for: UIControl.Event.touchUpInside)
        headView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.top.bottom.left.equalTo(headView)
            make.width.equalTo(64)
        }
        
        okBtn = UIButton(type: UIButton.ButtonType.system)
        okBtn.setTitle(okBtnText, for: UIControl.State.normal)
        okBtn.setTitleColor(okBtnTextColor, for: .normal)
        okBtn.titleLabel?.font = UIFont.systemFont(ofSize: UIDevice.currentDeviceType() == "iPad" ? 17 : 15)
        okBtn.addTarget(self, action: #selector(clickOKBtn), for: UIControl.Event.touchUpInside)
        headView.addSubview(okBtn)
        
        okBtn.snp.makeConstraints { make in
            make.top.right.bottom.equalTo(headView)
            make.width.equalTo(64)
        }
        
        dateAndtimeView = UIView()
        headView.addSubview(dateAndtimeView)
        dateAndtimeView.snp.makeConstraints { make in
            make.center.equalTo(headView)
        }
        
        let date = Date()
        let year = date.year
        let month = date.month
        let day = date.day
        currentDate = date.formatterDate(formatter: "YYYY-MM-dd")
        currentTime = date.formatterDate(formatter: "HH:mm")

        dateBtn = UIButton()
        dateBtn.layer.shadowColor = UIColor.clear.cgColor
        dateBtn.backgroundColor = UIColor.clear
        dateBtn.layer.shadowOffset = CGSize(width: 0, height: 1)
        dateBtn.layer.shadowOpacity = 1
        dateBtn.layer.shadowRadius = 4
        dateBtn.layer.cornerRadius = 4
        dateBtn.setTitle("  \(year)年\(month)月\(day)日  ", for: UIControl.State.normal)
        dateBtn.setTitleColor(dateBtnSelectedColor, for: UIControl.State.selected)
        dateBtn.setTitleColor(dateBtnNormalColor, for: UIControl.State.normal)
        dateBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        dateBtn.isSelected = true
        dateBtn.addTarget(self, action: #selector(clickTimeBtn(_:)), for: UIControl.Event.touchUpInside)
        dateAndtimeView.addSubview(dateBtn)
        dateBtn.snp.makeConstraints { make in
            make.top.equalTo(dateAndtimeView).offset(2)
            make.bottom.equalTo(dateAndtimeView).offset(-2)
            make.left.equalTo(2)
        }

        timeBtn = UIButton()
        timeBtn.layer.shadowColor = UIColor.clear.cgColor
        timeBtn.backgroundColor = UIColor.clear
        timeBtn.layer.shadowOffset = CGSize(width: 0, height: 1)
        timeBtn.layer.shadowOpacity = 1
        timeBtn.layer.shadowRadius = 4
        timeBtn.layer.cornerRadius = 4
        timeBtn.setTitle("  \(currentTime ?? "")  ", for: UIControl.State.normal)
        timeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        timeBtn.setTitleColor(dateBtnSelectedColor, for: UIControl.State.selected)
        timeBtn.setTitleColor(dateBtnNormalColor, for: UIControl.State.normal)
        timeBtn.isSelected = false
        timeBtn.addTarget(self, action: #selector(clickTimeBtn(_:)), for: UIControl.Event.touchUpInside)
        dateAndtimeView.addSubview(timeBtn)
        timeBtn.snp.makeConstraints { make in
            make.top.bottom.equalTo(dateBtn)
            make.left.equalTo(dateBtn.snp.right).offset(2)
            make.right.equalTo(dateAndtimeView).offset(-2)
        }
        
        dateLabel = UILabel()
        dateLabel.isHidden = true
        dateLabel.text = "  \(year)年\(month)月  "
        dateLabel.font = UIFont.boldSystemFont(ofSize: 16)
        dateLabel.textColor = dateBtnSelectedColor
        dateAndtimeView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.center.equalTo(dateAndtimeView)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func clickTimeBtn(_ button: UIButton) {
        if !button.isSelected {
            button.isSelected = true
            if button == dateBtn {
                timeBtn.isSelected = false
                if showDateBtnShadowColor {
                    dateBtn.layer.shadowColor = dateBtnShadowColor.cgColor
                    dateBtn.backgroundColor = dateBtnBgColor
                    timeBtn.layer.shadowColor = UIColor.clear.cgColor
                    timeBtn.backgroundColor = UIColor.clear
                }
                if pickerStyle == .datePicker {
                    UIView.animate(withDuration: 0.33) {
                        self.calendarView.frame.origin.x = 0
                        self.timePickerView.frame.origin.x = self.baseView.frame.size.width
                    }
                } else if pickerStyle == .singlePicker {
                    UIView.animate(withDuration: 0.33) {
                        self.calendarView.frame.origin.x = 0
                        self.singlePickerView.frame.origin.x = self.baseView.frame.size.width
                    }
                } else if pickerStyle == .dateTimeAndSecond {
                    UIView.animate(withDuration: 0.33) {
                        self.calendarView.frame.origin.x = 0
                        self.dateTimePickerView.frame.origin.x = self.baseView.frame.size.width
                    }
                }
            } else {
                dateBtn.isSelected = false
                if showDateBtnShadowColor {
                    timeBtn.layer.shadowColor = dateBtnShadowColor.cgColor
                    timeBtn.backgroundColor = dateBtnBgColor
                    dateBtn.layer.shadowColor = UIColor.clear.cgColor
                    dateBtn.backgroundColor = UIColor.clear
                }
                if pickerStyle == .datePicker {
                    if !baseView.subviews.contains(timePickerView) {
                        self.baseView.addSubview(self.timePickerView)
                    }
                    UIView.animate(withDuration: 0.33) {
                        self.calendarView.frame.origin.x = -self.baseView.frame.size.width
                        self.timePickerView.frame.origin.x = 0
                    }
                } else if pickerStyle == .singlePicker {
                    if !baseView.subviews.contains(singlePickerView) {
                        self.baseView.addSubview(self.singlePickerView)
                    }
                    UIView.animate(withDuration: 0.33) {
                        self.calendarView.frame.origin.x = -self.baseView.frame.size.width
                        self.singlePickerView.frame.origin.x = 0
                    }
                    self.singlePickerView.relodPickerView()
                } else if pickerStyle == .dateTimeAndSecond {
                    
                    if !baseView.subviews.contains(dateTimePickerView) {
                        self.baseView.addSubview(self.dateTimePickerView)
                    }
                    UIView.animate(withDuration: 0.33) {
                        self.calendarView.frame.origin.x = -self.baseView.frame.size.width
                        self.dateTimePickerView.frame.origin.x = 0
                    }
                    self.dateTimePickerView.relodPickerView()
                }
            }
        }
    }
    
    // MARK: - CalendarViewDelegate
    func didSelectedDate(selecteDate: Date) {
        let selectedYear = selecteDate.year
        let selectedMonth = selecteDate.month
        let selectedDay = selecteDate.day
        currentDate = selecteDate.formatterDate(formatter: "YYYY-MM-dd")
        dateBtn.setTitle("  \(selectedYear)年\(selectedMonth)月\(selectedDay)日  ", for: UIControl.State.normal)
        
        if isAllowSelectTime {
            dateBtn.isSelected = false
            timeBtn.isSelected = true
            if showDateBtnShadowColor {
                timeBtn.layer.shadowColor = dateBtnShadowColor.cgColor
                timeBtn.backgroundColor = dateBtnBgColor
                dateBtn.layer.shadowColor = UIColor.clear.cgColor
                dateBtn.backgroundColor = UIColor.clear
            }
            if pickerStyle == .datePicker {
                if !baseView.subviews.contains(timePickerView) {
                    self.baseView.addSubview(self.timePickerView)
                }
                UIView.animate(withDuration: 0.33) {
                    self.calendarView.frame.origin.x = -self.baseView.frame.size.width
                    self.timePickerView.frame.origin.x = 0
                }
            } else if pickerStyle == .singlePicker {
                if !baseView.subviews.contains(singlePickerView) {
                    self.baseView.addSubview(self.singlePickerView)
                }

                UIView.animate(withDuration: 0.33) {
                    self.calendarView.frame.origin.x = -self.baseView.frame.size.width
                    self.singlePickerView.frame.origin.x = 0
                }
                self.singlePickerView.relodPickerView()
            }  else if pickerStyle == .dateTimeAndSecond {
                if !baseView.subviews.contains(dateTimePickerView) {
                    self.baseView.addSubview(self.dateTimePickerView)
                }
                UIView.animate(withDuration: 0.33) {
                    self.calendarView.frame.origin.x = -self.baseView.frame.size.width
                    self.dateTimePickerView.frame.origin.x = 0
                }
                self.dateTimePickerView.relodPickerView()
            } else if pickerStyle == .dateRange {
                dateLabel.text = "  \(selectedYear)年\(selectedMonth)月  "
            }
        } else {
            if pickerStyle == .dateRange {
                dateLabel.text = "  \(selectedYear)年\(selectedMonth)月  "
            }
        }
    }
    func disSelectedRangeDate(dateRange: NCDateRangeModel) {
        if pickerStyle == .dateRange {
            dateRangeModel = dateRange
       }
    }
    
    // MARK: - TimePickerViewDelegate
    func selectedTime(time: String) {
        timeBtn.setTitle("  \(time)  ", for: UIControl.State.normal)
        currentTime = time
    }
    
    // MARK: - NCSinglePickerViewDelegate
    func selectedSingle(singleStr: String) {
        timeBtn.setTitle("  \(singleStr)  ", for: UIControl.State.normal)
        singleSelectedData = singleStr
    }
    
    // MARK: - NCDateTimeAndSecondPickerViewDelegate
    func selectedTimeAndSecond(timeStr: String) {
        timeBtn.setTitle("  \(timeStr)  ", for: UIControl.State.normal)
        currentTime = timeStr
    }

    /// 显示
    open func show() {
        keyWindow?.addSubview(self)
        keyWindow?.bringSubviewToFront(self)
        UIView.animate(withDuration: 0.21, animations: {
            self.baseView.transform = CGAffineTransform(translationX: 0, y:  -baseViewHeight)
            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }, completion: { (finish: Bool) in
            self.baseView.addSubview(self.calendarView)
        })
        
        var year = selectedDay.year
        var month = selectedDay.month
        var day = selectedDay.day
        var formatTime = "HH:mm"
        currentDate = selectedDay.formatterDate(formatter: "YYYY-MM-dd")
        if pickerStyle == .dateTimeAndSecond {
            formatTime = "HH:mm:ss"
        }
        currentTime = selectedDay.formatterDate(formatter: formatTime)
        dateBtn.setTitle("  \(year)年\(month)月\(day)日  ", for: UIControl.State.normal)
        
        self.calendarView.currentDate = selectedDay
        if let _ = self.minimumDate, let _ = self.maximumDate {
            var currDate = DateComponents()
            currDate.year = selectedDay.year
            currDate.month = selectedDay.month
            currDate.day = selectedDay.day
            if !self.calendarView.dateWithinDateRange(minimumDate, maximumDate, currDate: currDate) {
                self.calendarView.currentDate = minimumDate
                year = minimumDate!.year
                month = minimumDate!.month
                day = minimumDate!.day
            }
        }
        self.calendarView.selectedDay = selectedDay
        self.calendarView.pickerStyle = pickerStyle
        
        if pickerStyle == .datePicker || pickerStyle == .dateTimeAndSecond {
            timeBtn.setTitle("  " + currentTime + "  ", for: UIControl.State.normal)
            if pickerStyle == .dateTimeAndSecond {
                dateTimePickerView.selectedDay = selectedDay
            } else {
                timePickerView.selectedDay = selectedDay
            }
        } else if pickerStyle == .singlePicker {
            timeBtn.setTitle("  \(singleSelectedData)  ", for: UIControl.State.normal)
        } else if pickerStyle == .dateRange {
            dateLabel.isHidden = false
            dateBtn.isHidden = true
            timeBtn.isHidden = true
            dateLabel.text = "  \(year)年\(month)月  "
        }
    }
    
    @objc private func clickCancelBtn() {
        close()
    }
    
    @objc private func clickOKBtn() {
        if isAllowSelectTime == true {
            if pickerStyle == .datePicker || pickerStyle == .dateTimeAndSecond {
                selectedBack!(currentDate + " " + currentTime, "", NCDateRangeModel())
            } else if pickerStyle == .singlePicker {
                selectedBack!(currentDate, singleSelectedData, NCDateRangeModel())
            } else if pickerStyle == .dateRange {
                selectedBack!(currentDate, "", dateRangeModel)
            }else {
                selectedBack!(currentDate, "", NCDateRangeModel())
            }
        } else {
            selectedBack!(currentDate, "", NCDateRangeModel())
        }
        close()
    }
    @objc private func close() {
        UIView.animate(withDuration: 0.15, animations: {
            self.baseView.transform = CGAffineTransform.identity
            self.backgroundColor = .clear
        }) { (finish: Bool) in
            self.removeFromSuperview()
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != self {
            return false
        }
        return true
    }
    
}
//****************************< 以下日历模块 >************************************
// MARK: - 日历模块
/// 日历
protocol CalendarViewDelegate:NSObjectProtocol {
    func didSelectedDate(selecteDate: Date)
    func disSelectedRangeDate(dateRange: NCDateRangeModel)
}
class CalendarView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {

    var dateRangeModel: NCDateRangeModel = NCDateRangeModel()
    // 背景view的颜色
    open var viewbackgroundColor: UIColor = .white {
        didSet {
            backgroundColor = viewbackgroundColor
        }
    }
    // 周标题的文字颜色
    open var weekTitleColor: UIColor = .black {
        didSet {
            reloadWeekTitleView()
        }
    }
    // 不是当前月份的日期的文字颜色
    open var dayColor: UIColor = UIColor.hex(hex: 0xE0E2E4) {
        didSet {
            collectionView.reloadData()
        }
    }
    // 是当前月份的日期的文字颜色
    open var currentMonthTextColor: UIColor = UIColor.hex(hex: 0x313439) {
        didSet {
            collectionView.reloadData()
        }
    }
    // 选中的是当天的背景颜色
    open var currentDayColor: UIColor = UIColor.hex(hex: 0x2395FF) {
        didSet {
            collectionView.reloadData()
        }
    }
    // 选中的不是当天的背景颜色
    open var currentDisDayColor: UIColor = UIColor.hex(hex: 0xEEEEEE) {
        didSet {
            collectionView.reloadData()
        }
    }
    // 每个月的1号的文字
    open var firstDayColor: UIColor = UIColor.hex(hex: 0x1890FF) {
        didSet {
            collectionView.reloadData()
        }
    }
    // 今天的日期文字颜色
    open var currentDayTextColor: UIColor = UIColor.hex(hex: 0x313439) {
        didSet {
            collectionView.reloadData()
        }
    }
    // specify min/max date range. default is nil. When min > max, the values are ignored.
    // default is nil
    open var minimumDate: Date? = nil {
        didSet {
            collectionView.reloadData()
        }
    }
    
    open var maximumDate: Date? = nil {
        didSet {
            collectionView.reloadData()
        }
    }
    var collectionView: UICollectionView!
    var weekTitleArrs: [UILabel] = []
    var currentDate : Date! = Date()
    var selectedDay: Date! = Date()
    weak var delegate: CalendarViewDelegate?
    var labelHeight: CGFloat = 30
    
    var pickerStyle: NCCalendarMode = .datePicker ///< 选择样式 默认 datePicker

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = viewbackgroundColor
        creatWeekTitle()
        
        collectionView = UICollectionView(frame: CGRect(x: 10, y: labelHeight, width: self.frame.size.width - 20, height: self.frame.size.height - labelHeight), collectionViewLayout: CalendarLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        addSubview(collectionView)
        
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.setContentOffset(CGPoint(x: 0, y: (self.frame.size.height - labelHeight)*1), animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func creatWeekTitle() {
        let titles = ["日", "一", "二", "三", "四", "五", "六"]
        for i in 0..<titles.count {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = weekTitleColor
            label.text = titles[i]
            addSubview(label)
            let leftX = 10 + (((kScreen_width - 20 - calendarItemMargin) / 7) * CGFloat(i)) + 8 * CGFloat(i)
            label.snp.makeConstraints { make in
                make.top.equalTo(self)
                make.left.equalTo(leftX)
                make.width.equalTo((kScreen_width - 20 - calendarItemMargin) / 7)
                make.height.equalTo(labelHeight)
            }
            weekTitleArrs.append(label)
        }
    }
    func reloadWeekTitleView() {
        for weekTitleView in weekTitleArrs {
            weekTitleView.textColor = weekTitleColor
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42*3
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let dateModel: NCCurrentDateModel = NCCurrentDateModel(daysInThisMonth: currentDate.totalDaysInThisMonth, firstWeekDay: currentDate.firstWeekDayInThisMonth, currentMonth: currentDate.month, currentYear: currentDate.year, lastMonthDate: currentDate.lastMonth, nextMonthDate: currentDate.nextMonth)

        if pickerStyle == .dateRange {
            return makeDateRangeCell(indexPath, dateModel)
        } else {
            return makeDatePickerCell(indexPath, dateModel)
        }
    }
    
    //MARK: - 日期单选选择Cell
    func makeDatePickerCell(_ indexPath: IndexPath, _ dateModel: NCCurrentDateModel) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CalendarCell
        cell.textFont = cell.textFont
        
        let i = (indexPath.row - 42)
        
        if i < dateModel.firstWeekDay { // 不是当前显示的日期 // 上个月
            let lastDay = (dateModel.daysInLastMonth - dateModel.firstWeekDay + 1 + i)
            if lastDay == 1 {
                cell.text = "\(dateModel.lastMonth)月"
            } else if lastDay <= 0 {
                let doubleLastMonthDate = dateModel.lastMonthDate.lastMonth
                let daysInDoubleLastMonth = doubleLastMonthDate.totalDaysInThisMonth
                cell.text = "\(daysInDoubleLastMonth + lastDay)"
            } else {
                cell.text = String(lastDay)
            }
            cell.textColor = dayColor
            cell.bgViewColor = UIColor.clear
            cell.isUserInteractionEnabled = false
        } else if i > dateModel.firstWeekDay + dateModel.daysInThisMonth - 1 { // 下个月
            let nextCurrentDay = (i - dateModel.firstWeekDay - dateModel.daysInThisMonth + 1)
            if nextCurrentDay <= dateModel.daysInNextMonth {
                if nextCurrentDay == 1 {
                    cell.text = String(dateModel.nextMonth) + "月"
                } else {
                    cell.text = String(nextCurrentDay)
                }
            } else {
                let doubleNextMonthCurrentDay = (nextCurrentDay - dateModel.daysInNextMonth)
                if doubleNextMonthCurrentDay == 1 {
                    if dateModel.nextMonth == 12 {
                        cell.text = "1月"
                    } else {
                        cell.text = "\(dateModel.nextMonth + 1)月"
                    }
                } else {
                    cell.text = "\(doubleNextMonthCurrentDay)"
                }
            }
            cell.textColor = dayColor
            cell.bgViewColor = UIColor.clear
            cell.isUserInteractionEnabled = false
        } else {
            let currentDay = (i - dateModel.firstWeekDay + 1)
            var currDate = DateComponents()
            currDate.year = dateModel.currentYear
            currDate.month = dateModel.currentMonth
            currDate.day = currentDay
            if dateEquationDate(Date(), currDate: currDate) {// 今天的日期
                cell.text = "今"
                cell.textColor = currentMonthTextColor
                if dateEquationDate(selectedDay, currDate: currDate) { // 选中的是当天
                    cell.textColor = .white
                    cell.textBoldFont = cell.textBoldFont
                    cell.bgViewColor = currentDayColor
                } else {
                    cell.bgViewColor = currentDisDayColor
                    cell.textColor = currentDayTextColor
                }
            } else { //  当前显示月
                if currentDay == 1 { // 当前月的1号
                    cell.text = String(dateModel.currentMonth) + "月"
                    if dateEquationDate(selectedDay, currDate: currDate) {
                        cell.textColor = .white
                        cell.textBoldFont = cell.textBoldFont
                        cell.bgViewColor = currentDayColor
                    } else {
                        cell.textColor = firstDayColor
                        cell.bgViewColor = UIColor.clear
                    }
                } else {
                    if dateEquationDate(selectedDay, currDate: currDate) {
                        cell.textColor = .white
                        cell.textBoldFont = cell.textBoldFont
                        cell.bgViewColor = currentDayColor
                    } else {
                        cell.textColor = currentMonthTextColor
                        cell.bgViewColor = UIColor.clear
                    }
                    cell.text = String(currentDay)
                }
            }
            cell.isUserInteractionEnabled = true
            minAndMaximumDateComponents(cell, currDate)
        }
        return cell
    }
    
    //MARK: - 日期范围选择Cell
    func makeDateRangeCell(_ indexPath: IndexPath, _ dateModel: NCCurrentDateModel) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CalendarCell
        cell.textFont = cell.textFont
        cell.textFont = 15
        
        let i = (indexPath.row - 42)
        
        if i < dateModel.firstWeekDay { // 不是当前显示的日期 // 上个月
            let lastDay = (dateModel.daysInLastMonth - dateModel.firstWeekDay + 1 + i)
            if lastDay == 1 {
                cell.text = "\(dateModel.lastMonth)月"
            } else if lastDay <= 0 {
                let doubleLastMonthDate = dateModel.lastMonthDate.lastMonth
                let daysInDoubleLastMonth = doubleLastMonthDate.totalDaysInThisMonth
                cell.text = "\(daysInDoubleLastMonth + lastDay)"
            } else {
                cell.text = String(lastDay)
            }
            cell.textColor = dayColor
            cell.bgViewColor = UIColor.clear
            cell.isUserInteractionEnabled = false
        } else if i > dateModel.firstWeekDay + dateModel.daysInThisMonth - 1 { // 下个月
            let nextCurrentDay = (i - dateModel.firstWeekDay - dateModel.daysInThisMonth + 1)
            if nextCurrentDay <= dateModel.daysInNextMonth {
                if nextCurrentDay == 1 {
                    cell.text = String(dateModel.nextMonth) + "月"
                } else {
                    cell.text = String(nextCurrentDay)
                }
            } else {
                let doubleNextMonthCurrentDay = (nextCurrentDay - dateModel.daysInNextMonth)
                if doubleNextMonthCurrentDay == 1 {
                    if dateModel.nextMonth == 12 {
                        cell.text = "1月"
                    } else {
                        cell.text = "\(dateModel.nextMonth + 1)月"
                    }
                } else {
                    cell.text = "\(doubleNextMonthCurrentDay)"
                }
            }
            cell.textColor = dayColor
            cell.bgViewColor = UIColor.clear
            cell.isUserInteractionEnabled = false
        } else {
            let currentDay = (i - dateModel.firstWeekDay + 1)
            var currDate = DateComponents()
            currDate.year = dateModel.currentYear
            currDate.month = dateModel.currentMonth
            currDate.day = currentDay
            if dateEquationDate(Date(), currDate: currDate) {// 今天的日期
//                    cell.text = String(currentDay)
                cell.text = "今"
                cell.textColor = currentMonthTextColor
                if dateWithinDateRange(dateRangeModel.startDate, dateRangeModel.endDate, currDate: currDate) {
                    cell.textColor = UIColor.hex(hex: 0x0876FB, alpha: 1.0)
                    cell.bgViewColor = UIColor.hex(hex: 0x0876FB, alpha: 0.1)
                    if dateEquationDate(dateRangeModel.startDate, currDate: currDate) {
                        cell.textColor = .white
                        cell.bgViewColor = currentDayColor
                        cell.text = "开始"
                    }
                    if dateEquationDate(dateRangeModel.endDate, currDate: currDate) {
                        cell.textColor = .white
                        cell.bgViewColor = currentDayColor
                        cell.text = "结束"
                    }
                } else {
                    cell.bgViewColor = currentDisDayColor
                    cell.textColor = currentDayTextColor
                }
            } else { //  当前显示月
                if currentDay == 1 { // 当前月的1号
                    cell.text = String(dateModel.currentMonth) + "月"
                    if dateWithinDateRange(dateRangeModel.startDate, dateRangeModel.endDate, currDate: currDate) {
                        cell.textColor = UIColor.hex(hex: 0x0876FB, alpha: 1.0)
                        cell.bgViewColor = UIColor.hex(hex: 0x0876FB, alpha: 0.1)
                        if dateEquationDate(dateRangeModel.startDate, currDate: currDate) {
                            cell.textColor = .white
                            cell.bgViewColor = currentDayColor
                            cell.text = "开始"
                        }
                        if dateEquationDate(dateRangeModel.endDate, currDate: currDate) {
                            cell.textColor = .white
                            cell.bgViewColor = currentDayColor
                            cell.text = "结束"
                        }
                    } else {
                        cell.textColor = firstDayColor
                        cell.bgViewColor = UIColor.clear
                    }
                } else {
                    cell.text = String(currentDay)
                    if dateWithinDateRange(dateRangeModel.startDate, dateRangeModel.endDate, currDate: currDate) {
                        cell.textColor = UIColor.hex(hex: 0x0876FB, alpha: 1.0)
                        cell.bgViewColor = UIColor.hex(hex: 0x0876FB, alpha: 0.1)
                        if dateEquationDate(dateRangeModel.startDate, currDate: currDate) {
                            cell.textColor = .white
                            cell.bgViewColor = currentDayColor
                            cell.text = "开始"
                        }
                        if dateEquationDate(dateRangeModel.endDate, currDate: currDate) {
                            cell.textColor = .white
                            cell.bgViewColor = currentDayColor
                            cell.text = "结束"
                        }
                        if dateRangeModel.startDate == dateRangeModel.endDate {
                            cell.textColor = .white
                            cell.bgViewColor = currentDayColor
                            cell.text = "同"
                        }
                    } else {
                        cell.textColor = currentMonthTextColor
                        cell.bgViewColor = UIColor.clear
                    }
                }
            }
            cell.isUserInteractionEnabled = true
            minAndMaximumDateComponents(cell, currDate)
        }
        return cell
    }
    
    //MARK: - Processing of minimum and maximum time settings
    func minAndMaximumDateComponents( _ cell: CalendarCell, _ currDate: DateComponents) {
        let skip = skipMinAndMaximumDate()
        if let _ = self.minimumDate, !skip {
            if let date = Calendar.current.date(from: currDate) {
                if numberOfDaysWithFromDate(minimumDate!, toDate: date) < 0 {
                    cell.textColor = dayColor
                    cell.bgViewColor = UIColor.clear
                    cell.isUserInteractionEnabled = false
                }
            }
        }
        
        if let _ = self.maximumDate, !skip {
            if let date = Calendar.current.date(from: currDate) {
                if numberOfDaysWithFromDate(maximumDate!, toDate: date) > 0 {
                    cell.textColor = dayColor
                    cell.bgViewColor = UIColor.clear
                    cell.isUserInteractionEnabled = false
                }
            }
        }
    }
    //MARK: - Do you want to skip setting the minimum and maximum time
    func skipMinAndMaximumDate() -> Bool {
        var skip: Bool = false
        if let _ = self.minimumDate, let _ = self.maximumDate {
            if numberOfDaysWithFromDate(minimumDate!, toDate: maximumDate!) < 0 {
                skip = true
            }
        }
        return skip
    }
    
    /// 上次选中的日期, 默认初始值为当前日期
    var lastSelected: NSInteger! = (42 + Date().firstWeekDayInThisMonth - 1 + Date().day)
    func changeLastSelected() {
        if selectedDay != Date() {
            lastSelected = (42 + selectedDay.firstWeekDayInThisMonth - 1 + selectedDay.day)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 计算选中的日期
        let firstWeekDay = currentDate.firstWeekDayInThisMonth
        let clickDay = (indexPath.row - 42 - firstWeekDay + 1)
        
        let clickDate = calculateDate(clickDay: clickDay)
        if pickerStyle == .dateRange {
            var number = 0
            if let _ = dateRangeModel.startDate, let _ = dateRangeModel.endDate {
                dateRangeModel.startDate = nil
                dateRangeModel.endDate = nil
            }
            if let startDate = dateRangeModel.startDate {
                number = numberOfDaysWithFromDate(startDate, toDate: clickDate)
            }
            if dateRangeModel.startDate == nil {
                dateRangeModel.startDate = clickDate
            } else {
                if number < 0 {
                    dateRangeModel.startDate = clickDate
                    dateRangeModel.endDate = nil
                } else {
                    dateRangeModel.endDate = clickDate
                }
            }
            if let _ = dateRangeModel.startDate, let _ = dateRangeModel.endDate {
                delegate?.disSelectedRangeDate(dateRange: dateRangeModel)
            }
            collectionView.reloadData()
            
        } else {
            changeLastSelected()
            selectedDay = clickDate
            delegate?.didSelectedDate(selecteDate: clickDate)
            
            // 刷新上次选中和当前选中的items
            var arr = [IndexPath]()
            if lastSelected != indexPath.row {
                arr.append(IndexPath(item: lastSelected, section: 0))
            }
            arr.append(IndexPath(item: indexPath.row, section: 0))
            collectionView.reloadItems(at: arr)
            
            lastSelected = indexPath.row // 记录选中的item
        }
    }
    
    func calculateDate(clickDay: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.day = -currentDate.day + clickDay
        let clickDate = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        return clickDate!
    }
    
    //MARK: - 计算日期差的方法
    func numberOfDaysWithFromDate(_ fromDate: Date, toDate: Date) -> NSInteger {
        
        let calendar = NSCalendar.init(identifier: .gregorian)
        
        let comp = calendar!.components(.day, from: fromDate, to: toDate, options: .wrapComponents)
        
        return (comp.day)!
    }
    // 日期相等
    func dateEquationDate(_ startOrEndDate: Date?, currDate: DateComponents) -> Bool {
        
        let calendar = Calendar.current

        var nowDate = Date()

        if let date = calendar.date(from: currDate) {
            nowDate = date
        }
        if let _ = startOrEndDate {
            var startOrEndDates = DateComponents()
            startOrEndDates.year = startOrEndDate?.year
            startOrEndDates.month = startOrEndDate?.month
            startOrEndDates.day = startOrEndDate?.day
            
            // 获取起始日期和结束日期的日期对象
            let startOrEnd = calendar.date(from: startOrEndDates)!
            
            // 判断当前日期等于在起始日期或结束日期
            if nowDate == startOrEnd{
                return true
            } else {
                return false
            }
        }
        return false
    }
    // 日期在日期范围之间
    func dateWithinDateRange(_ startDate: Date?, _ endDate: Date?, currDate: DateComponents) -> Bool {
        
        let calendar = Calendar.current

        var nowDate = Date()

        if let date = calendar.date(from: currDate) {
            nowDate = date
        }
        if let _ = startDate, let _ = endDate {
            // 起始日期
            var startDates = DateComponents()
            startDates.year = startDate?.year
            startDates.month = startDate?.month
            startDates.day = startDate?.day
            
            // 结束日期
            var endDates = DateComponents()
            endDates.year = endDate?.year
            endDates.month = endDate?.month
            endDates.day = endDate?.day
            
            // 获取起始日期和结束日期的日期对象
            let start = calendar.date(from: startDates)!
            let end = calendar.date(from: endDates)!
            
            // 判断当前日期是否在起始日期和结束日期之间
            if nowDate >= start && nowDate <= end {
                return true
            } else {
                return false
            }
        } else {
            var date: Date?
            if let _ = startDate {
                date = startDate
            }
            if let _ = endDate {
                date = endDate
            }
            return dateEquationDate(date, currDate: currDate)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let direction = lroundf(Float(collectionView.contentOffset.y / collectionView.frame.size.height))
        
        if direction == 0 {
            self.currentDate = self.currentDate.lastMonth
            reseData()
        }
        if direction == 2 {
            self.currentDate = self.currentDate.nextMonth
            reseData()
        }
    }
    func reseData() {
        if pickerStyle == .dateRange {
            let clickDate = calculateDate(clickDay: 1)
            delegate?.didSelectedDate(selecteDate: clickDate)
        }
        collectionView.setContentOffset(CGPoint(x: 0, y: (self.frame.size.height - labelHeight)*1), animated: false)
        collectionView.reloadData()
    }
    
}
// MARK: - CalendarLayout
/// 定义 UICollectionViewFlowLayout
class CalendarLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        itemSize = CGSize(width: calendarItemWH, height: calendarItemWH)
        scrollDirection = .vertical
        minimumLineSpacing = 8
        minimumInteritemSpacing = 8
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - 日历单元 cell
/// 日历单元 cell
class CalendarCell: UICollectionViewCell {
    open var text: String! {
        set {
            self.textLbl.text = newValue
        }
        get {
            return self.textLbl.text
        }
    }
    // 日期文字字号 -- 不加粗
    open var textFont: CGFloat! {
        set {
            self.textLbl.font = UIFont.systemFont(ofSize: newValue)
        }
        get {
            return self.textLbl.font.pointSize
        }
    }
    // 选中的日期文字加粗
    open var textBoldFont: CGFloat! {
        set {
            self.textLbl.font = UIFont.boldSystemFont(ofSize: newValue)
        }
        get {
            return self.textLbl.font.pointSize
        }
    }
    open var textColor: UIColor! {
        set {
            self.textLbl.textColor = newValue
        }
        get {
            return self.textLbl.textColor
        }
    }
    open var bgViewColor: UIColor! {
        set {
            self.textBgView.backgroundColor = newValue
        }
        get {
            return self.textBgView.backgroundColor
        }
    }
    
    open var textBgViewSize: CGFloat = 36 {
        didSet {
            textBgView.snp.updateConstraints { make in
                make.size.equalTo(textBgViewSize)
            }
            textBgView.layer.cornerRadius = textBgViewSize / 2
        }
    }
    
    private lazy var textBgView: UIView = {
        let bgView = UIView()
        bgView.layer.cornerRadius = textBgViewSize / 2
        bgView.backgroundColor = .clear
        return bgView
    }()
    private lazy var textLbl: UILabel = {
        let label = UILabel(frame: self.bounds)
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        if #available(iOS 10.0, *) {
            label.adjustsFontForContentSizeCategory = true
        }
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(textBgView)
        addSubview(textLbl)
        textBgView.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.size.equalTo(textBgViewSize)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
