//
//  ScreenRotatorDemoState.swift
//  ScreenRotatorDemo
//
//  Created by 周健平 on 2022/10/28.
//

import Foundation

@available(iOS 13.0, *)
public class ScreenRotatorState: ObservableObject {
    @Published public var orientation: ScreenRotator.Orientation = ScreenRotator.shared.orientation {
        didSet { ScreenRotator.shared.rotation(to: orientation) }
    }
    
    @Published public var isLockOrientation: Bool = ScreenRotator.shared.isLockOrientationWhenDeviceOrientationDidChange {
        didSet { ScreenRotator.shared.isLockOrientationWhenDeviceOrientationDidChange = isLockOrientation }
    }
    
    @Published public var isLockLandscape: Bool = ScreenRotator.shared.isLockLandscapeWhenDeviceOrientationDidChange {
        didSet { ScreenRotator.shared.isLockLandscapeWhenDeviceOrientationDidChange = isLockLandscape }
    }
    
    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange),
                                               name: ScreenRotator.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(lockOrientationWhenDeviceOrientationDidChange),
                                               name: ScreenRotator.lockOrientationWhenDeviceOrientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(lockLandscapeWhenDeviceOrientationDidChange),
                                               name: ScreenRotator.lockLandscapeWhenDeviceOrientationDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func orientationDidChange() {
        orientation = ScreenRotator.shared.orientation
    }
    
    @objc private func lockOrientationWhenDeviceOrientationDidChange() {
        isLockOrientation = ScreenRotator.shared.isLockOrientationWhenDeviceOrientationDidChange
    }
    
    @objc private func lockLandscapeWhenDeviceOrientationDidChange() {
        isLockLandscape = ScreenRotator.shared.isLockLandscapeWhenDeviceOrientationDidChange
    }
}
