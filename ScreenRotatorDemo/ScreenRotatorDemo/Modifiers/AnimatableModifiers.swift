//
//  AnimatableModifiers.swift
//  ScreenRotatorDemo
//
//  Created by 周健平 on 2022/10/28.
//

import SwiftUI

struct AnimatableForegroundColorModifier: AnimatableModifier {
    let fromRgba: UIColor.RGBA
    let toRgba: UIColor.RGBA
    var progress: CGFloat
    
    init(from: UIColor, to: UIColor, progress: CGFloat) {
        self.fromRgba = from.rgba
        self.toRgba = to.rgba
        self.progress = progress
    }
    
    var color: Color {
        let rgba = UIColor.RGBA.fromSourceRgba(fromRgba, toTargetRgba: toRgba, progress: progress)
        return Color(red: rgba.r / 255, green: rgba.g / 255, blue: rgba.b / 255, opacity: rgba.a)
    }
    
    var animatableData: CGFloat {
        set {
            if newValue < 0 {
                progress = 0
            } else if newValue > 1 {
                progress = 1
            } else {
                progress = newValue
            }
        }
        get { progress }
    }

    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
    }
}

extension View {
    func animatableForegroundColor(from: UIColor,
                                   to: UIColor,
                                   progress: CGFloat) -> some View {
        modifier(AnimatableForegroundColorModifier(from: from, to: to, progress: progress))
    }
}
