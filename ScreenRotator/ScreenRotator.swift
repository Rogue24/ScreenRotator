//
//  ScreenRotatorDemo.swift
//  ScreenRotatorDemo
//
//  Created by 周健平 on 2022/10/28.
//

import UIKit

public final class ScreenRotator {
    // MARK: - 构造器
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive),
                                               name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange),
                                               name: UIDevice.orientationDidChangeNotification, object: nil)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 可旋转的屏幕方向【枚举】
    public enum Orientation: CaseIterable {
        case portrait           // 竖屏 手机头在上边
        case portraitUpsideDown // 竖屏 手机头在下边
        case landscapeLeft      // 横屏 手机头在左边
        case landscapeRight     // 横屏 手机头在右边
    }
    
    // MARK: - 属性
    /// 单例
    public static let shared = ScreenRotator()
    
    /// 可否旋转
    public private(set) var isEnabled = true
    
    /// 当前屏幕方向（UIInterfaceOrientationMask）
    public private(set) var orientationMask: UIInterfaceOrientationMask = .portrait {
        didSet {
            guard orientationMask != oldValue else { return }
            publishOrientationMaskDidChange()
        }
    }
    
    /// 是否允许转向`竖屏-手机头在下边`的方向（默认不允许）
    public var isAllowPortraitUpsideDown: Bool = false {
        didSet {
            guard !isAllowPortraitUpsideDown, orientationMask == .portraitUpsideDown else { return }
            rotationToPortrait()
        }
    }
    
    /// 是否锁定屏幕方向（当控制中心禁止了竖屏锁定，为`true`则不会【随手机摆动自动改变】屏幕方向）
    /// - Note: 即便锁定了（`true`）也能通过该类去旋转屏幕方向
    public var isLockOrientationWhenDeviceOrientationDidChange = true {
        didSet {
            guard isLockOrientationWhenDeviceOrientationDidChange != oldValue else { return }
            publishLockOrientationWhenDeviceOrientationDidChange()
        }
    }
    
    /// 是否锁定横屏方向（当控制中心禁止了竖屏锁定，为`true`则【仅限横屏的两个方向会随手机摆动自动改变】屏幕方向）
    /// - Note: 即便锁定了（`true`）也能通过该类去旋转屏幕方向
    public var isLockLandscapeWhenDeviceOrientationDidChange = false {
        didSet {
            guard isLockLandscapeWhenDeviceOrientationDidChange != oldValue else { return }
            publishLockLandscapeWhenDeviceOrientationDidChange()
        }
    }
    
    /// 是否正在竖屏（手机头在上边）
    public var isPortrait: Bool { orientationMask == .portrait }
    
    /// 当前屏幕方向（`UIInterfaceOrientationMask` --> `ScreenRotator.Orientation`）
    public var orientation: Orientation {
        switch orientationMask {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        case .landscape:
            let deviceOrientation = UIDevice.current.orientation
            switch deviceOrientation {
            case .landscapeLeft:
                return .landscapeLeft
            case .landscapeRight:
                return .landscapeRight
            case .portraitUpsideDown:
                return .portraitUpsideDown
            default:
                return .portrait
            }
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
    // MARK: - 状态发生改变的【通知】
    /// <屏幕方向>发生改变的通知
    /// - Parameters:
    /// - object: `orientationMask`（UIInterfaceOrientationMask）
    public static let orientationDidChangeNotification = Notification.Name("ScreenRotatorOrientationDidChangeNotification")
    
    /// <是否锁定屏幕方向>发生改变的通知
    /// - Parameters:
    /// - object: `isLockOrientationWhenDeviceOrientationDidChange`（Bool）
    public static let lockOrientationWhenDeviceOrientationDidChangeNotification = Notification.Name("ScreenRotatorLockOrientationWhenDeviceOrientationDidChangeNotification")
    
    /// <是否锁定横屏方向>发生改变的通知
    /// - Parameters:
    /// - object: `isLockLandscapeWhenDeviceOrientationDidChange`（Bool）
    public static let lockLandscapeWhenDeviceOrientationDidChangeNotification = Notification.Name("ScreenRotatorLockLandscapeWhenDeviceOrientationDidChangeNotification")
    
    // MARK: - 状态发生改变的【回调闭包】
    /// <屏幕方向>发生改变的回调闭包
    public var orientationMaskDidChange: ((_ orientationMask: UIInterfaceOrientationMask) -> ())?
    
    /// <是否锁定屏幕方向>发生改变的回调闭包
    public var lockOrientationWhenDeviceOrientationDidChange: ((_ isLock: Bool) -> ())?
    
    /// <是否锁定横屏方向>发生改变的回调闭包
    public var lockLandscapeWhenDeviceOrientationDidChange: ((_ isLock: Bool) -> ())?
}

// MARK: - 私有API
private extension ScreenRotator {
    static func convertInterfaceOrientationMaskToDeviceOrientation(_ orientationMask: UIInterfaceOrientationMask) -> UIDeviceOrientation {
        switch orientationMask {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        case .landscape:
            return .landscapeLeft
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }

    static func convertDeviceOrientationToInterfaceOrientationMask(_ orientation: UIDeviceOrientation) -> UIInterfaceOrientationMask {
        switch orientation {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
    static func setNeedsUpdateOfSupportedInterfaceOrientations(_ currentVC: UIViewController, _ presentedVC: UIViewController?) {
        if #available(iOS 16.0, *) { currentVC.setNeedsUpdateOfSupportedInterfaceOrientations() }
        
        let currentPresentedVC = currentVC.presentedViewController
        
        if let currentPresentedVC, currentPresentedVC != presentedVC {
            setNeedsUpdateOfSupportedInterfaceOrientations(currentPresentedVC, nil)
        }
        
        for childVC in currentVC.children {
            setNeedsUpdateOfSupportedInterfaceOrientations(childVC, currentPresentedVC)
        }
    }
    
    func rotation(to orientationMask: UIInterfaceOrientationMask) {
        guard isEnabled else { return }
        guard self.orientationMask != orientationMask else { return }
        
        // 更新并广播屏幕方向
        self.orientationMask = orientationMask
        
        // 控制横竖屏
        if #available(iOS 16.0, *) {
            // `iOS16`由于不能再设置`UIDevice.orientation`来控制横竖屏了，所以`UIDeviceOrientationDidChangeNotification`将由系统自动发出，
            // 即手机的摆动就会自动收到通知，不能自己控制，因此不能监听该通知来适配UI，
            // 重写`UIViewController`的`-viewWillTransitionToSize:withTransitionCoordinator:`方法来监听屏幕的旋转并适配UI。
            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: orientationMask)
            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene else { continue }
                // 一般来说app只有一个`windowScene`，而`windowScene`内可能有多个`window`，
                // 例如Demo中至少有两个`window`：第一个是app主体的`window`，第二个则是`FunnyButton`所在的`window`，
                // 所以需要遍历全部`window`进行旋转，保证全部`window`都能保持一致的屏幕方向。
                
                // 📢【注意】要在全部`window`调用`requestGeometryUpdate`之前，
                // 先对`vc`调用`attemptRotationToDeviceOrientation`，否则会报错（虽然对屏幕旋转没影响）：
                // ↓↓↓
                // PS:`iOS16`之后`attemptRotationToDeviceOrientation`建议不再使用（虽然还起效），
                // 而是调用`setNeedsUpdateOfSupportedInterfaceOrientations`进行屏幕旋转。
                for window in windowScene.windows {
                    guard let rootViewController = window.rootViewController else { continue }
                    // 由于Demo中只用到`rootViewController`控制屏幕方向，所以只对`rootViewController`调用即可。
                    rootViewController.setNeedsUpdateOfSupportedInterfaceOrientations()
                    // 若需要全部控制器都执行`setNeedsUpdateOfSupportedInterfaceOrientations`，可调用该函数：
                    // Self.setNeedsUpdateOfSupportedInterfaceOrientations(rootViewController, nil)
                }
                // ↓↓↓
                for window in windowScene.windows {
                    window.windowScene?.requestGeometryUpdate(geometryPreferences)
                }
            }
        } else {
            // `iOS16`之前调用`attemptRotationToDeviceOrientation`屏幕才会旋转。
            //【注意】要在确定改变的方向【设置之后】才调用，否则会旋转到【设置之前】的方向
            UIViewController.attemptRotationToDeviceOrientation()
            
            // `iOS16`之前修改"orientation"后会直接影响`UIDevice.currentDevice.orientation`；
            // `iOS16`之后不能再通过设置`UIDevice.orientation`来控制横竖屏了，修改"orientation"无效。
            let currentDevice = UIDevice.current
            let deviceOrientation = Self.convertInterfaceOrientationMaskToDeviceOrientation(orientationMask)
            currentDevice.setValue(NSNumber(value: deviceOrientation.rawValue), forKeyPath: "orientation")
        }
    }
}

// MARK: 监听通知
private extension ScreenRotator {
    // 不活跃了，也就是进后台了
    @objc func willResignActive() {
        isEnabled = false
    }
    
    // 活跃了，也就是从后台回来了
    @objc func didBecomeActive() {
        isEnabled = true
    }
    
    // 设备方向发生改变
    @objc func deviceOrientationDidChange() {
        guard isEnabled else { return }
        guard !isLockOrientationWhenDeviceOrientationDidChange else { return }
        
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .unknown, .faceUp, .faceDown:
            return
        case .portraitUpsideDown:
            if !isAllowPortraitUpsideDown {
                return
            }
        default:
            break
        }
        
        if isLockLandscapeWhenDeviceOrientationDidChange, !deviceOrientation.isLandscape {
            return
        }
        
        let orientationMask = Self.convertDeviceOrientationToInterfaceOrientationMask(deviceOrientation)
        rotation(to: orientationMask)
    }
}

// MARK: 广播通知
private extension ScreenRotator {
    func publishOrientationMaskDidChange() {
        orientationMaskDidChange?(orientationMask)
        NotificationCenter.default.post(name: Self.orientationDidChangeNotification, object: orientationMask)
    }
    
    func publishLockOrientationWhenDeviceOrientationDidChange() {
        lockOrientationWhenDeviceOrientationDidChange?(isLockOrientationWhenDeviceOrientationDidChange)
        NotificationCenter.default.post(name: Self.lockOrientationWhenDeviceOrientationDidChangeNotification,
                                        object: isLockOrientationWhenDeviceOrientationDidChange)
    }
    
    func publishLockLandscapeWhenDeviceOrientationDidChange() {
        lockLandscapeWhenDeviceOrientationDidChange?(isLockLandscapeWhenDeviceOrientationDidChange)
        NotificationCenter.default.post(name: Self.lockLandscapeWhenDeviceOrientationDidChangeNotification,
                                        object: isLockLandscapeWhenDeviceOrientationDidChange)
    }
}

// MARK: - 公开API
public extension ScreenRotator {
    /// 旋转至目标方向
    /// - Parameters:
    ///   - orientation: 目标方向（ScreenRotator.Orientation）
    func rotation(to orientation: Orientation) {
        guard isEnabled else { return }
        let orientationMask: UIInterfaceOrientationMask
        switch orientation {
        case .landscapeLeft:
            orientationMask = .landscapeRight
        case .landscapeRight:
            orientationMask = .landscapeLeft
        case .portraitUpsideDown:
            if !isAllowPortraitUpsideDown {
                return
            }
            orientationMask = .portraitUpsideDown
        default:
            orientationMask = .portrait
        }
        rotation(to: orientationMask)
    }
    
    /// 旋转至竖屏（手机头在上边）
    func rotationToPortrait() {
        rotation(to: UIInterfaceOrientationMask.portrait)
    }
    
    /// 旋转至竖屏（手机头在下边）
    func rotationToPortraitUpsideDown() {
        guard isAllowPortraitUpsideDown else { return }
        rotation(to: UIInterfaceOrientationMask.portraitUpsideDown)
    }
    
    /// 旋转至横屏（如果锁定了屏幕，则转向手机头在左边）
    func rotationToLandscape() {
        guard isEnabled else { return }
        var orientationMask = Self.convertDeviceOrientationToInterfaceOrientationMask(UIDevice.current.orientation)
        if orientationMask == .portrait || orientationMask == .portraitUpsideDown {
            orientationMask = .landscapeRight
        }
        rotation(to: orientationMask)
    }
    
    /// 旋转至横屏（手机头在左边）
    func rotationToLandscapeLeft() {
        rotation(to: UIInterfaceOrientationMask.landscapeRight)
    }
    
    /// 旋转至横屏（手机头在右边）
    func rotationToLandscapeRight() {
        rotation(to: UIInterfaceOrientationMask.landscapeLeft)
    }
    
    /// 横竖屏切换
    func toggleOrientation() {
        guard isEnabled else { return }
        var orientationMask = Self.convertDeviceOrientationToInterfaceOrientationMask(UIDevice.current.orientation)
        if orientationMask == self.orientationMask {
            orientationMask = (self.orientationMask == .portrait || self.orientationMask == .portraitUpsideDown) ? .landscapeRight : .portrait
        }
        rotation(to: orientationMask)
    }
}
