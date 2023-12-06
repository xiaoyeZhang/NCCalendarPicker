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
private let calendarItemWH: CGFloat = (kScreen_width - 20 - 6 * 8) / 7
private let headViewH: CGFloat = 50
private var baseViewHeight = headViewH + 30 + 6 * calendarItemWH + 6 * 8 + UIDevice.vg_safeDistanceBottom()

public class NCCalendarPicker: UIView, UIGestureRecognizerDelegate, CalendarViewDelegate, TimePickerViewDelegate, NCSinglePickerViewDelegate {
    public typealias DidSelectedDate = (_ date: String, _ singlePickerStr: String) -> Void

    /// 日期选择器枚举
    public enum ZXYPickerStyle {
        case datePicker // 时间选择器
        case singlePicker // 单项选择器
    }
    open var singlePickerDatas: [String] = ["上午","下午"] {
        didSet {
            singleSelectedData = singlePickerDatas.first!
        }
    } // 单项选择器数据源
    open var singleSelectedData: String = ""
    open var selectedDay: Date! = Date()  // 选择的时间
    private var baseView: UIView!
    private var headView: UIView!
    private var dateAndtimeView: UIView!
    private var cancelBtn: UIButton!
    private var okBtn: UIButton!
    private var dateBtn: UIButton!
    private var timeBtn: UIButton!
    private var currentDate: String!
    private var currentTime: String!
    private var selectedBack: DidSelectedDate?
    
    private lazy var calendarView: CalendarView! = {
        let calendarView = CalendarView(frame: CGRect(x: 0, y: headViewH, width: kScreen_width, height: baseViewHeight - headViewH - UIDevice.vg_safeDistanceBottom()))
        calendarView.viewbackgroundColor = calendarViewBaseViewColor
        calendarView.delegate = self
        return calendarView
    }()
    
    private lazy var timePickerView: TimePickerView! = {
        let timePickerView = TimePickerView(frame: calendarView.frame)
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
    
    // 是否需要选择时间
    open var isAllowSelectTime: Bool! = true {
        didSet {
            if isAllowSelectTime == true {
                timeBtn.isHidden = false
            } else {
                timeBtn.isHidden = true
            }
        }
    }
    // 背景view的颜色
    open var baseViewColor: UIColor = .white {
        didSet {
            baseView.backgroundColor = baseViewColor
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

    //MARK:calendarView的颜色控制
    // timePickerView的背景颜色
    open var calendarViewBaseViewColor: UIColor = .white {
        didSet {
            calendarView.viewbackgroundColor = calendarViewBaseViewColor
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
    // 每个月的1号的文字
    open var firstDayColor: UIColor = UIColor.hex(hex: 0x1890FF) {
        didSet {
            calendarView.firstDayColor = firstDayColor
            calendarView.collectionView.reloadData()
        }
    }
    
    open var pickerStyle: ZXYPickerStyle = .datePicker ///< 选择样式 默认 datePicker

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
            make.top.bottom.equalTo(headView)
            make.centerX.equalTo(headView)
        }
        
        let date = Date()
        let year = date.year
        let month = date.month
        let day = date.day
        currentDate = date.formatterDate(formatter: "YYYY-MM-dd")
        currentTime = date.formatterDate(formatter: "HH:mm")

        dateBtn = UIButton()
        dateBtn.setTitle("\(year)年\(month)月\(day)日", for: UIControl.State.normal)
        dateBtn.setTitleColor(dateBtnSelectedColor, for: UIControl.State.selected)
        dateBtn.setTitleColor(dateBtnNormalColor, for: UIControl.State.normal)
        dateBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        dateBtn.isSelected = true
        dateBtn.addTarget(self, action: #selector(clickTimeBtn(_:)), for: UIControl.Event.touchUpInside)
        dateAndtimeView.addSubview(dateBtn)
        dateBtn.snp.makeConstraints { make in
            make.top.bottom.equalTo(dateAndtimeView)
            make.left.equalTo(10)
        }

        timeBtn = UIButton()
        timeBtn.setTitle(currentTime, for: UIControl.State.normal)
        timeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        timeBtn.setTitleColor(dateBtnSelectedColor, for: UIControl.State.selected)
        timeBtn.setTitleColor(dateBtnNormalColor, for: UIControl.State.normal)
        timeBtn.isSelected = false
        timeBtn.addTarget(self, action: #selector(clickTimeBtn(_:)), for: UIControl.Event.touchUpInside)
        dateAndtimeView.addSubview(timeBtn)
        timeBtn.snp.makeConstraints { make in
            make.top.bottom.equalTo(dateAndtimeView)
            make.left.equalTo(dateBtn.snp.right).offset(10)
            make.right.equalTo(dateAndtimeView).offset(-10)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CalendarViewDelegate
    @objc func clickTimeBtn(_ button: UIButton) {
        if !button.isSelected {
            button.isSelected = true
            if button == dateBtn {
                timeBtn.isSelected = false
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
                }
            } else {
                dateBtn.isSelected = false
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
        dateBtn.setTitle("\(selectedYear)年\(selectedMonth)月\(selectedDay)日", for: UIControl.State.normal)
        
        if isAllowSelectTime {
            dateBtn.isSelected = false
            timeBtn.isSelected = true
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
            }
            
        }
    }
    // MARK: - TimePickerViewDelegate
    func selectedTime(time: String) {
        timeBtn.setTitle(time, for: UIControl.State.normal)
        currentTime = time
    }
    // MARK: - NCSinglePickerViewDelegate
    func selectedSingle(singleStr: String) {
        timeBtn.setTitle(singleStr, for: UIControl.State.normal)
        singleSelectedData = singleStr
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
        
        let year = selectedDay.year
        let month = selectedDay.month
        let day = selectedDay.day
        currentDate = selectedDay.formatterDate(formatter: "YYYY-MM-dd")
        currentTime = selectedDay.formatterDate(formatter: "HH:mm")
        dateBtn.setTitle("\(year)年\(month)月\(day)日", for: UIControl.State.normal)
        
        self.calendarView.currentDate = selectedDay
        self.calendarView.selectedDay = selectedDay
        
        if pickerStyle == .datePicker {
            timeBtn.setTitle(currentTime, for: UIControl.State.normal)
            timePickerView.selectedDay = selectedDay
        } else if pickerStyle == .singlePicker {
            timeBtn.setTitle(singleSelectedData, for: UIControl.State.normal)
        }
    }
    
    @objc private func clickCancelBtn() {
        close()
    }
    
    @objc private func clickOKBtn() {
        if isAllowSelectTime == true {
            if pickerStyle == .datePicker {
                selectedBack!(currentDate + " " + currentTime, "")
            } else if pickerStyle == .singlePicker {
                selectedBack!(currentDate, singleSelectedData)
            } else {
                selectedBack!(currentDate, "")
            }
        } else {
            selectedBack!(currentDate, "")
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
}
class CalendarView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    // 背景view的颜色
    open var viewbackgroundColor: UIColor = .white {
        didSet {
            backgroundColor = viewbackgroundColor
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
    
    var collectionView: UICollectionView!
    var currentDate : Date! = Date()
    var selectedDay: Date! = Date()
    weak var delegate: CalendarViewDelegate?
    var labelHeight: CGFloat = 30
    
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
            label.font = UIFont.systemFont(ofSize: 13)
            label.text = titles[i]
            addSubview(label)
            let leftX = 10 + (((kScreen_width - 20 - 6 * 8) / 7) * CGFloat(i)) + 8 * CGFloat(i)
            label.snp.makeConstraints { make in
                make.top.equalTo(self)
                make.left.equalTo(leftX)
                make.width.equalTo((kScreen_width - 20 - 6 * 8) / 7)
                make.height.equalTo(labelHeight)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42*3
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CalendarCell
        
        let daysInThisMonth = currentDate.totalDaysInThisMonth
        let firstWeekDay = currentDate.firstWeekDayInThisMonth
        let currentMonth = currentDate.month
        let currentYear = currentDate.year
        let lastMonthDate = currentDate.lastMonth
        let lastMonth = lastMonthDate.month
        let daysInLastMonth = lastMonthDate.totalDaysInThisMonth
        let nextMonthDate = currentDate.nextMonth
        let nextMonth = nextMonthDate.month
        let daysInNextMonth = nextMonthDate.totalDaysInThisMonth
        
        let i = (indexPath.row - 42)
        
        if i < firstWeekDay { // 不是当前显示的日期 // 上个月
            let lastDay = (daysInLastMonth - firstWeekDay + 1 + i)
            if lastDay == 1 {
                cell.text = "\(lastMonth)月"
            } else if lastDay <= 0 {
                let doubleLastMonthDate = lastMonthDate.lastMonth
                let daysInDoubleLastMonth = doubleLastMonthDate.totalDaysInThisMonth
                cell.text = "\(daysInDoubleLastMonth + lastDay)"
            } else {
                cell.text = String(lastDay)
            }
            cell.textColor = dayColor
            cell.bgViewColor = UIColor.clear
            cell.isUserInteractionEnabled = false
        } else if i > firstWeekDay + daysInThisMonth - 1 { // 下个月
            let nextCurrentDay = (i - firstWeekDay - daysInThisMonth + 1)
            if nextCurrentDay <= daysInNextMonth {
                if nextCurrentDay == 1 {
                    cell.text = String(nextMonth) + "月"
                } else {
                    cell.text = String(nextCurrentDay)
                }
            } else {
                let doubleNextMonthCurrentDay = (nextCurrentDay - daysInNextMonth)
                if doubleNextMonthCurrentDay == 1 {
                    if nextMonth == 12 {
                        cell.text = "1月"
                    } else {
                        cell.text = "\(nextMonth + 1)月"
                    }
                } else {
                    cell.text = "\(doubleNextMonthCurrentDay)"
                }
            }
            cell.textColor = dayColor
            cell.bgViewColor = UIColor.clear
            cell.isUserInteractionEnabled = false
        } else {
            let currentDay = (i - firstWeekDay + 1)
            if currentDay == Date().day // 今天的日期
                && currentMonth == Date().month
                && currentYear == Date().year {
                cell.text = String(currentDay)
                cell.textColor = currentMonthTextColor
                if currentDay == selectedDay.day // 选中的是当天
                    && currentMonth == selectedDay.month
                    && currentYear == selectedDay.year {
                    cell.textColor = .white
                    cell.bgViewColor = currentDayColor
                } else {
                    cell.bgViewColor = currentDisDayColor
                    cell.textColor = currentMonthTextColor
                }
            } else { //  当前显示月
                if currentDay == 1 { // 当前月的1号
                    cell.text = String(currentMonth) + "月"
                    if currentDay == selectedDay.day
                        && currentMonth == selectedDay.month
                        && currentYear == selectedDay.year {
                        cell.textColor = .white
                        cell.bgViewColor = currentDayColor
                    } else {
                        cell.textColor = firstDayColor
                        cell.bgViewColor = UIColor.clear
                    }
                } else {
                    if currentDay == selectedDay.day
                        && currentMonth == selectedDay.month
                        && currentYear == selectedDay.year {
                        cell.textColor = .white
                        cell.bgViewColor = currentDayColor
                    } else {
                        cell.textColor = currentMonthTextColor
                        cell.bgViewColor = UIColor.clear
                    }
                    cell.text = String(currentDay)
                }
            }
            cell.isUserInteractionEnabled = true
        }
        return cell
    }
    
    /// 上次选中的日期, 默认初始值为当前日期
    var lastSelected: NSInteger! = (42 + Date().firstWeekDayInThisMonth - 1 + Date().day)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 计算选中的日期
        let firstWeekDay = currentDate.firstWeekDayInThisMonth
        let clickDay = (indexPath.row - 42 - firstWeekDay + 1)
        
        var dateComponents = DateComponents()
        dateComponents.day = -currentDate.day + clickDay
        let clickDate = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        selectedDay = clickDate
        delegate?.didSelectedDate(selecteDate: clickDate!)
        
        // 刷新上次选中和当前选中的items
        var arr = [IndexPath]()
        if lastSelected != indexPath.row {
            arr.append(IndexPath(item: lastSelected, section: 0))
        }
        arr.append(IndexPath(item: indexPath.row, section: 0))
        collectionView.reloadItems(at: arr)
        
        lastSelected = indexPath.row // 记录选中的item
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
    private lazy var textBgView: UIView = {
        let bgView = UIView()
        bgView.layer.cornerRadius = 8
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
            make.size.equalTo(32)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//***************************< 以下时间选择模块 >**********************************
// MARK: - 时间选择模块
protocol TimePickerViewDelegate:NSObjectProtocol {
    func selectedTime(time: String)
}
class TimePickerView: UIView {
    
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
    weak var delegate: TimePickerViewDelegate?
    
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
