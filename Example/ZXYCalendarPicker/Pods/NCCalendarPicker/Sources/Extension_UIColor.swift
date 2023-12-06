//
//  Extension_UIColor.swift
//  ZXYCalendarPickerDemo
//
//  Created by who on 2023/10/11.
//

import Foundation
import UIKit

extension UIColor {
    
    // MARK: - 16进制色值(0x000000) -> UIColor
    /// 16进制色值(0x000000) -> UIColor
    ///
    /// - Parameter hex: 16进制色值(0x000000)
    /// - Returns: UIColor
    class func hex(hex: Int) -> UIColor {
        return UIColor.hex(hex: hex, alpha: 1.0)
    }
    /// 16进制色值(0x000000) -> UIColor
    ///
    /// - Parameters:
    ///   - hex: 16进制色值(0x000000)
    ///   - alpha: 透明度
    /// - Returns: UIColor
    class func hex(hex: Int, alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat((hex >> 16) & 0xFF)/255.0, green: CGFloat((hex >> 8) & 0xFF)/255.0, blue: CGFloat(hex & 0xFF)/255.0, alpha: alpha)
    }
    
    // MARK: - 获取 UIColor 的 16进制色值(#000000)
    /// 获取 UIColor 的 16进制色值(#000000)
    var hex: String {
        var color = self
        if color.cgColor.numberOfComponents < 4 {
            let components = color.cgColor.components
            
            color = UIColor(red: components![0], green: components![0], blue: components![0], alpha: components![1])
        }
        if color.cgColor.colorSpace?.model != CGColorSpaceModel.rgb {
            return "#FFFFFF"
        }
        return String(format: "#%02X%02X%02X", Int(color.cgColor.components![0]*255.0), Int(color.cgColor.components![1]*255.0), Int(color.cgColor.components![2]*255.0))
    }
    
    // MARK: - RGB -> UIColor
    class func rgba(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    // MARK: - RGBA -> UIColor
    class func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return rgba(red: red, green: green, blue: blue, alpha: 1.0)
    }
    // MARK: - 获取 UIColor 的 rgba 值
    /// 获取 UIColor 的 rgba 值
    var rgba: [Int] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [Int(red*255.0), Int(green*255.0), Int(blue*255.0), Int(alpha)]
    }
    // MARK: - 随机色
    /// 随机色
    ///
    /// - Returns: 随机色
    class func randomColor() -> UIColor {
        let red = CGFloat(arc4random()%255)
        let green = CGFloat(arc4random()%255)
        let blue = CGFloat(arc4random()%255)
        let color = UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
        return color
    }
    
    
    
}
