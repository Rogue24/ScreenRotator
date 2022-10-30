//
//  MainWindow.swift
//  ScreenRotatorDemo
//
//  Created by 周健平 on 2022/10/28.
//

import UIKit

class MainWindow: UIWindow {
    static let shared = MainWindow()
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
