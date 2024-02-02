//
//  Extension_UIView.swift
//  ZXYCalendarPickerDemo
//
//  Created by who on 2023/10/11.
//

import Foundation
import UIKit

extension UIView {
    // MARK: - UIView 圆角
    /// 切圆角
    ///
    /// - Parameter cornerRadius: 圆角半径
    func roundedCorners(cornerRadius: CGFloat) {
        roundedCorners(cornerRadius: cornerRadius, borderWidth: 0, borderColor: nil)
    }

    /// 圆角边框设置
    ///
    /// - Parameters:
    ///   - cornerRadius: 圆角半径
    ///   - borderWidth: 边款宽度
    ///   - borderColor: 边款颜色
    func roundedCorners(cornerRadius: CGFloat?, borderWidth: CGFloat?, borderColor: UIColor?) {
        self.layer.cornerRadius = cornerRadius!
        self.layer.borderWidth = borderWidth!
        self.layer.borderColor = borderColor?.cgColor
        self.layer.masksToBounds = true
    }

    /// 设置指定角的圆角
    ///
    /// - Parameters:
    ///   - cornerRadius: 圆角半径
    ///   - rectCorners: 指定切圆角的角(多个角)
    func roundedCorners(cornerRadius: CGFloat?, rectCorners: [UIRectCorner] = []) {
        var corners:UIRectCorner = UIRectCorner()
        for rectCorner in rectCorners {
            corners.insert(rectCorner)
        }
        self.roundedCorners(cornerRadius: cornerRadius, rectCorner: corners)
    }
    
    /// 设置指定角的圆角
    ///
    /// - Parameters:
    ///   - cornerRadius: 圆角半径
    ///   - rectCorner: 指定切圆角的角
    func roundedCorners(cornerRadius: CGFloat?, rectCorner: UIRectCorner?) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: rectCorner!, cornerRadii: CGSize(width: cornerRadius!, height: cornerRadius!))
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path.cgPath
        self.layer.mask = layer
    }

    // MARK: - UIView 渐变色
    /// 渐变色
    ///
    /// - Parameters:
    ///   - colors: 渐变的颜色
    ///   - locations: 每个颜色所在的位置(0为开始位...1为结束位)
    ///   - startPoint: 开始坐标[0...1]
    ///   - endPoint: 结束坐标[0...1]
    func gradientColor(colors: [CGColor], locations: [NSNumber], startPoint: CGPoint, endPoint: CGPoint) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        /*
         表示竖向渐变
         gradientLayer.startPoint = CGPoint(x: 0, y: 0)
         gradientLayer.endPoint = CGPoint(x: 0, y: 1)
         */
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = self.frame
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - UIView 模糊效果
    /// view 添加模糊效果
    ///
    /// - Parameter style: UIBlurEffectStyle
    func addBlurEffect(style: UIBlurEffect.Style) {
        let effect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.frame = self.bounds
        self.backgroundColor = .clear
        self.addSubview(effectView)
        self.sendSubviewToBack(effectView)
    }
}
