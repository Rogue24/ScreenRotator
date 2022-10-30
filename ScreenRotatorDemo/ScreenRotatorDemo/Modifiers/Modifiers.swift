//
//  Modifiers.swift
//  ScreenRotatorDemo
//
//  Created by 周健平 on 2022/10/28.
//

import SwiftUI

struct ShowStyle: ViewModifier {
    let isShow: Bool
    
    let fromScale: CGFloat
    let toScale: CGFloat
    
    let fromOpacity: CGFloat
    let toOpacity: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isShow ? 1 : 0.8)
            .opacity(isShow ? 1 : 0)
            .animation(.spring(response: 0.4,
                               dampingFraction: 0.45,
                               blendDuration: 0), value: isShow)
    }
}

extension View {
    func showStyle(isShow: Bool,
                   fromScale: CGFloat = 0.8, toScale: CGFloat = 1,
                   fromOpacity: CGFloat = 0, toOpacity: CGFloat = 1) -> some View {
        modifier(
            ShowStyle(isShow: isShow,
                      fromScale: fromScale,
                      toScale: toScale,
                      fromOpacity: fromOpacity,
                      toOpacity: toOpacity)
        )
    }
}
