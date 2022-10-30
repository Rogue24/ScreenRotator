//
//  ScreenRotatorDemoState.swift
//  ScreenRotatorDemo
//
//  Created by 周健平 on 2022/10/28.
//

class ScreenRotatorState: ObservableObject {
    @Published var orientation: ScreenRotator.Orientation = ScreenRotator.shared.orientation {
        didSet { ScreenRotator.shared.rotation(to: orientation) }
    }
    
    @Published var isLockOrientation: Bool = ScreenRotator.shared.isLockOrientationWhenDeviceOrientationDidChange {
        didSet { ScreenRotator.shared.isLockOrientationWhenDeviceOrientationDidChange = isLockOrientation }
    }
    
    @Published var isLockLandscape: Bool = ScreenRotator.shared.isLockLandscapeWhenDeviceOrientationDidChange {
        didSet { ScreenRotator.shared.isLockLandscapeWhenDeviceOrientationDidChange = isLockLandscape }
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange),
                                               name: ScreenRotator.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(lockOrientationWhenDeviceOrientationDidChange),
                                               name: ScreenRotator.lockOrientationWhenDeviceOrientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(lockLandscapeWhenDeviceOrientationDidChange),
                                               name: ScreenRotator.lockLandscapeWhenDeviceOrientationDidChangeNotification, object: nil)
    }
    
    @objc func orientationDidChange() {
        orientation = ScreenRotator.shared.orientation
    }
    
    @objc func lockOrientationWhenDeviceOrientationDidChange() {
        isLockOrientation = ScreenRotator.shared.isLockOrientationWhenDeviceOrientationDidChange
    }
    
    @objc func lockLandscapeWhenDeviceOrientationDidChange() {
        isLockLandscape = ScreenRotator.shared.isLockLandscapeWhenDeviceOrientationDidChange
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
