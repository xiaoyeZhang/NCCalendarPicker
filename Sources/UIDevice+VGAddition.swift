//
//  UIDevice+VGAddition.swift
//  ZXYCalendarPickerDemo
//
//  Created by who on 2023/10/11.
//

import Foundation
import UIKit

extension UIDevice {
    
    static func currentDeviceType() -> String {
        let deviceType = UIDevice.current.model
        return deviceType
    }
    /// 顶部安全区高度
    static func vg_safeDistanceTop() -> CGFloat {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            return window.safeAreaInsets.top
        } else if #available(iOS 11.0, *) {
            guard let window = UIApplication.shared.windows.first else { return 0 }
            return window.safeAreaInsets.top
        }
        return 0;
    }
    
    /// 底部安全区高度
    static func vg_safeDistanceBottom() -> CGFloat {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            return window.safeAreaInsets.bottom
        } else if #available(iOS 11.0, *) {
            guard let window = UIApplication.shared.windows.first else { return 0 }
            return window.safeAreaInsets.bottom
        }
        return 0;
    }
    
    /// 顶部状态栏高度（包括安全区）
    static func vg_statusBarHeight() -> CGFloat {
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let statusBarManager = windowScene.statusBarManager else { return 0 }
            statusBarHeight = statusBarManager.statusBarFrame.height
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        return statusBarHeight
    }
    
    /// 导航栏高度
    static func vg_navigationBarHeight() -> CGFloat {
        return 44.0
    }
    
    /// 状态栏+导航栏的高度
    static func vg_navigationFullHeight() -> CGFloat {
        return UIDevice.vg_statusBarHeight() + UIDevice.vg_navigationBarHeight()
    }
    
    /// 底部导航栏高度
    static func vg_tabBarHeight() -> CGFloat {
        return 49.0
    }
    
    /// 底部导航栏高度（包括安全区）
    @objc static func vg_tabBarFullHeight() -> CGFloat {
        return UIDevice.vg_tabBarHeight() + UIDevice.vg_safeDistanceBottom()
    }
}

