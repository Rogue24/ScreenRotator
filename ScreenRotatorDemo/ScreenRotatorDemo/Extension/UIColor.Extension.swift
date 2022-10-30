//
//  UIColor.Extension.swift
//  ScreenRotatorDemo
//
//  Created by 周健平 on 2022/10/28.
//

import UIKit

extension UIColor {
    struct RGBA: Equatable {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 1
        
        static func randomRGBA(_ a: CGFloat = 1.0) -> Self {
            RGBA(r: CGFloat.random(in: 0...255),
                 g: CGFloat.random(in: 0...255),
                 b: CGFloat.random(in: 0...255),
                 a: a)
        }
        
        static func == (rgba1: Self, rgba2: Self) -> Bool {
            (rgba1.r == rgba2.r) &&
            (rgba1.g == rgba2.g) &&
            (rgba1.b == rgba2.b) &&
            (rgba1.a == rgba2.a)
        }
        
        static func + (rgba1: Self, rgba2: Self) -> Self {
            RGBA(r: rgba1.r + rgba2.r,
                 g: rgba1.g + rgba2.g,
                 b: rgba1.b + rgba2.b,
                 a: rgba1.a + rgba2.a)
        }
        
        static func - (rgba1: Self, rgba2: Self) -> Self {
            RGBA(r: rgba1.r - rgba2.r,
                 g: rgba1.g - rgba2.g,
                 b: rgba1.b - rgba2.b,
                 a: rgba1.a - rgba2.a)
        }
        
        static func * (rgba: Self, progress: CGFloat) -> Self {
            RGBA(r: rgba.r * progress,
                 g: rgba.g * progress,
                 b: rgba.b * progress,
                 a: rgba.a * progress)
        }
        
        static func fromSourceToTargetRgba(_ sourceRgba: Self, _ differRgba: Self, progress: CGFloat) -> Self {
            sourceRgba + (differRgba * progress)
        }
        
        static func fromSourceRgba(_ sourceRgba: Self, toTargetRgba targetRgba: Self, progress: CGFloat) -> Self {
            sourceRgba + ((targetRgba - sourceRgba) * progress)
        }
    }
    
    // MARK: - 从颜色中获取rgba
    var rgba: RGBA {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return RGBA(r: r * 255, g: g * 255, b: b * 255, a: a)
    }
    
    // MARK: - 通过RGBA创建颜色
    class func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, a: CGFloat = 1) -> Self {
        Self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    class func rgba(_ rgba: RGBA) -> Self {
        Self.init(red: rgba.r / 255.0, green: rgba.g / 255.0, blue: rgba.b / 255.0, alpha: rgba.a)
    }
    
    // MARK: - 随机颜色
    class var randomColor: UIColor { UIColor.rgba(RGBA.randomRGBA()) }
    class func randomColor(_ a: CGFloat = 1.0) -> UIColor { UIColor.rgba(RGBA.randomRGBA(a)) }
}
