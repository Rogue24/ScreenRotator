//
//  Function.swift
//  ScreenRotatorDemo
//
//  Created by 周健平 on 2022/10/28.
//

import UIKit

/// 获取`KeyWindow`
func GetKeyWindow() -> UIWindow? {
    if #available(iOS 13.0, *) {
        for connectedScene in UIApplication.shared.connectedScenes {
            guard connectedScene.activationState == .foregroundActive else { continue }
            guard let windowScene = connectedScene as? UIWindowScene else { continue }
            for window in windowScene.windows where window.isKeyWindow {
                return window
            }
        }
    } else {
        for window in UIApplication.shared.windows where window.isKeyWindow {
            return window
        }
    }
    return nil
}

/// 获取`主Window`
func GetMainWindow() -> UIWindow? {
    // 一般来说第一个window就是app主体的window。
    if #available(iOS 13.0, *) {
        for connectedScene in UIApplication.shared.connectedScenes {
            guard let windowScene = connectedScene as? UIWindowScene else { continue }
            return windowScene.windows.first
        }
    } else {
        return UIApplication.shared.windows.first
    }
    return nil
}

/// 获取`下巴`高度
func GetDiffTabBarH() -> CGFloat {
    if #available(iOS 11.0, *) {
        return GetMainWindow()?.safeAreaInsets.bottom ?? 0
    }
    return 0
}

/// 获取`状态栏`高度
func GetStatusBarH() -> CGFloat {
    var h: CGFloat = 0
    if #available(iOS 11.0, *) {
        if let window = GetMainWindow() {
            if #available(iOS 13.0, *), let sbMgr = window.windowScene?.statusBarManager {
                h = sbMgr.statusBarFrame.height
            } else {
                h = window.safeAreaInsets.top
            }
        }
    } else {
        h = UIApplication.shared.statusBarFrame.height
    }
    return h
}

/// 获取最顶层的`ViewController` --- 从`主Window`开始查找
func GetTopMostViewController() -> UIViewController? {
    guard let rootVC = GetMainWindow()?.rootViewController else { return nil }
    return GetTopMostViewController(from: rootVC)
}

/// 获取最顶层的`ViewController` --- 从指定VC开始查找
func GetTopMostViewController(from vc: UIViewController) -> UIViewController {
    if let presentedVC = vc.presentedViewController {
        return GetTopMostViewController(from: presentedVC)
    }
    
    switch vc {
    case let navCtr as UINavigationController:
        guard let topVC = navCtr.topViewController else { return navCtr }
        return GetTopMostViewController(from: topVC)
        
    case let tabBarCtr as UITabBarController:
        guard let selectedVC = tabBarCtr.selectedViewController else { return tabBarCtr }
        return GetTopMostViewController(from: selectedVC)
        
    case let alertCtr as UIAlertController:
        guard let presentedVC = alertCtr.presentedViewController else { return alertCtr }
        return GetTopMostViewController(from: presentedVC)
        
    default:
        return vc
    }
}

