# ScreenRotator

A utility class that allows for rotating/locking screen orientation anytime, anywhere.

    Features:
        ✅ Supports rotation control in four directions:
            - Portrait: Top of the phone is up
            - Portrait: Top of the phone is down
            - Landscape: Top of the phone is to the left
            - Landscape: Top of the phone is to the right
        ✅ Allows control over whether the screen orientation changes automatically with device movement;
        ✅ Compatible with iOS 16;
        ✅ Supports Objective-C, Swift, and SwiftUI;
        ✅ Simple and easy-to-use API.

## Usage Examples:

- Rotating/Locking Screen Orientation Anytime, Anywhere

![ScreenRotator_1.gif](https://github.com/Rogue24/JPCover/raw/master/ScreenRotator/ScreenRotator_1.gif)

- `push` or `present` a new page with a different orientation than the current one

![ScreenRotator_2.gif](https://github.com/Rogue24/JPCover/raw/master/ScreenRotator/ScreenRotator_2.gif)

- Switching between portrait and landscape modes in videos

![ScreenRotator_3.gif](https://github.com/Rogue24/JPCover/raw/master/ScreenRotator/ScreenRotator_3.gif)

## Prerequisites:

1. To globally control screen orientation with the singleton `ScreenRotator.shared`, override the following method in `AppDelegate`:

```swift
func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    return ScreenRotator.shared.orientationMask
}
```

2. No need to override `supportedInterfaceOrientations` and `shouldAutorotate` in `UIViewController` anymore.

3. If you need to obtain real-time screen dimensions, override the following method in the respective `ViewController`:

```swift
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    // Example: Portrait --> Landscape
    
    // When the screen rotates, this function is automatically triggered by the system, and `size` represents the screen size after the rotation.
    print("size \(size)") // --- (926.0, 428.0)
    // Alternatively, you can also obtain the screen size after rotation through `UIScreen`.
    print("mainScreen \(UIScreen.main.bounds.size)") // --- (926.0, 428.0)

    // 📢 Note: If you attempt to retrieve screen-related information using `self.xxx` (such as `self.view.frame`), the size obtained at this point is still the size before the rotation.
    print("----------- Screen will rotate -----------")
    print("view.size \(view.frame.size)") // - (428.0, 926.0)
    print("window.size \(view.window?.size ?? .zero)") // - (428.0, 926.0)
    print("window.safeAreaInsets \(view.window?.safeAreaInsets ?? .zero)") // - UIEdgeInsets(top: 47.0, left: 0.0, bottom: 34.0, right: 0.0)
    
    // 📢 To obtain screen information after rotation, you need to wait until the next iteration of the `Runloop`.
    DispatchQueue.main.async {
        print("----------- Screen has rotated -----------")
        print("view.size \(self.view.frame.size)") // - (926.0, 428.0)
        print("window.size \(self.view.window?.size ?? .zero)") // - (926.0, 428.0)
        print("window.safeAreaInsets \(self.view.window?.safeAreaInsets ?? .zero)") // - UIEdgeInsets(top: 0.0, left: 47.0, bottom: 21.0, right: 47.0)
        print("==================================")
    }
}
```

4. If you need to listen for screen rotation, use `ScreenRotator.orientationDidChangeNotification` notification provided by this utility class or implement using closure:

```swift
ScreenRotator.shared.orientationMaskDidChange = { orientationMask in 
    // Update the orientation of the FunnyButton belonging to the window.
    FunnyButton.orientationMask = orientationMask
}
```

5. For **iPad App**, you need to go to `TARGETS` -> `General` -> `Deployment Info` -> enable `Requires full screen` to use code to rotate the screen:

![ScreenRotator_4.jpg](https://github.com/Rogue24/JPCover/raw/master/ScreenRotator/ScreenRotator_4.jpg)

## API:

Methods available through the singleton `ScreenRotator.shared`:

1. Rotate to target orientation

```swift
func rotation(to orientation: Orientation)
```

2. Rotate to Portrait (Top of the phone is up)

```swift
func rotationToPortrait()
```

3. Rotate to Portrait (Top of the phone is down)

```swift
func rotationToPortraitUpsideDown()
```

4. Rotate to Landscape (If screen is locked, rotates to left side of the phone)

```swift
func rotationToLandscape()
```

5. Rotate to Landscape (Top of the phone is to the left)

```swift
func rotationToLandscapeLeft()
```

6. Rotate to Landscape (Top of the phone is to the right)

```swift
func rotationToLandscapeRight()
```

7. Toggle between Portrait and Landscape

```swift
func toggleOrientation()
```

8. Is in Portrait mode (Top of the phone is up)

```swift
var isPortrait: Bool
```

9. Current screen orientation (ScreenRotator.Orientation)

```swift
var orientation: Orientation
```

10. Allow rotation to Portrait (Top of the phone is down) (Default is false)

```swift
var isAllowPortraitUpsideDown: Bool = false
```

11. Lock screen orientation (If Portrait Orientation Lock is disabled in Control Center, setting this to `true` will prevent automatic screen rotation based on device movement)

```swift
var isLockOrientationWhenDeviceOrientationDidChange = true 
// Note: Even if locked (`true`), you can still change screen orientation using this tool
```

12. Lock Landscape orientation (If Portrait Orientation Lock is disabled in Control Center, setting this to `true` will allow screen rotation based on device movement, but only for landscape orientations)

```swift
var isLockLandscapeWhenDeviceOrientationDidChange = false 
// Note: Even if locked (`true`), you can still change screen orientation using this tool
```

13. Closure to handle changes in screen orientation:

```swift
var orientationMaskDidChange: ((_ orientationMask: UIInterfaceOrientationMask) -> ())?
```

14. Closure to handle changes in lock status for screen orientation:

```swift
var lockOrientationWhenDeviceOrientationDidChange: ((_ isLock: Bool) -> ())?
```

15. Closure to handle changes in lock status for landscape orientation:

```swift
var lockLandscapeWhenDeviceOrientationDidChange: ((_ isLock: Bool) -> ())?
```

## Observable Notifications:

1. Notification for changes in screen orientation:

- `ScreenRotator.orientationDidChangeNotification`
    - object: `orientationMask` (UIInterfaceOrientationMask)

2. Notification for changes in lock status for screen orientation:

- `ScreenRotator.lockOrientationWhenDeviceOrientationDidChangeNotification`
    - object: `isLockOrientationWhenDeviceOrientationDidChange` (Bool)

3. Notification for changes in lock status for landscape orientation:

- `ScreenRotator.lockLandscapeWhenDeviceOrientationDidChangeNotification`
    - object: `isLockLandscapeWhenDeviceOrientationDidChange` (Bool)

## Compatibility with OC & SwiftUI:

- Objective-C: Use `JPScreenRotator`, which is specifically written in OC, with the same usage as `ScreenRotator`.

- SwiftUI: Use `ScreenRotatorState` to update state.
  - Refer to the `RotatorView` in the Demo for usage details.

## Tips:

When `push` or `present` a new page with a different orientation than the current one, it is recommended to **rotate first** and then open after a delay of at least 0.1s to avoid screen orientation confusion. Example:

```swift
let testVC = UIViewController()

// 1. Rotate first
ScreenRotator.shared.rotation(to: .landscapeRight)

// 2. Open after a delay of at least 0.1s
DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
    if let navCtr = self.navigationController {
        navCtr.pushViewController(testVC, animated: true)
    } else {
        self.present(testVC, animated: true)
    }  
}
```

## Installation

ScreenRotator is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ScreenRotator'
```


# 中文介绍

屏幕旋转工具类，能通过代码随时随地旋转/锁定屏幕方向。

    Feature：
        ✅ 可控制旋转四个方向：
            - 竖屏：手机头在上边
            - 竖屏：手机头在下边
            - 横屏：手机头在左边
            - 横屏：手机头在右边
        ✅ 可控制是否随手机摆动自动改变屏幕方向；
        ✅ 适配iOS16；
        ✅ 兼容 OC & Swift & SwiftUI；
        ✅ API简单易用。

## 使用效果

- 随时随地旋转/锁定屏幕方向

![ScreenRotator_1.gif](https://github.com/Rogue24/JPCover/raw/master/ScreenRotator/ScreenRotator_1.gif)

- `push`或`present`一个跟当前方向不一样的新页面

![ScreenRotator_2.gif](https://github.com/Rogue24/JPCover/raw/master/ScreenRotator/ScreenRotator_2.gif)

- 视频的横竖屏切换

![ScreenRotator_3.gif](https://github.com/Rogue24/JPCover/raw/master/ScreenRotator/ScreenRotator_3.gif)

## 使用前提

1. 让单例`ScreenRotator.shared`**全局控制**屏幕方向，首先得在`AppDelegate`中重写：

```swift
func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    return ScreenRotator.shared.orientationMask
}
```

2. 不需要再重写`UIViewController`的`supportedInterfaceOrientations`和`shouldAutorotate`；

3. 如需获取屏幕实时尺寸，在对应`ViewController`中重写：

```swift
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    // 🌰🌰🌰：竖屏 --> 横屏
    
    // 当屏幕发生旋转时，系统会自动触发该函数，`size`为【旋转之后】的屏幕尺寸
    print("size \(size)") // --- (926.0, 428.0)
    // 或者通过`UIScreen`也能获取【旋转之后】的屏幕尺寸
    print("mainScreen \(UIScreen.main.bounds.size)") // --- (926.0, 428.0)

    // 📢 注意：如果想通过`self.xxx`去获取屏幕相关的信息（如`self.view.frame`），【此时】获取的尺寸还是【旋转之前】的尺寸
    print("----------- 屏幕即将旋转 -----------")
    print("view.size \(view.frame.size)") // - (428.0, 926.0)
    print("window.size \(view.window?.size ?? .zero)") // - (428.0, 926.0)
    print("window.safeAreaInsets \(view.window?.safeAreaInsets ?? .zero)") // - UIEdgeInsets(top: 47.0, left: 0.0, bottom: 34.0, right: 0.0)
    
    // 📢 想要获取【旋转之后】的屏幕信息，需要到`Runloop`的下一个循环才能获取
    DispatchQueue.main.async {
        print("----------- 屏幕已经旋转 -----------")
        print("view.size \(self.view.frame.size)") // - (926.0, 428.0)
        print("window.size \(self.view.window?.size ?? .zero)") // - (926.0, 428.0)
        print("window.safeAreaInsets \(self.view.window?.safeAreaInsets ?? .zero)") // - UIEdgeInsets(top: 0.0, left: 47.0, bottom: 21.0, right: 47.0)
        print("==================================")
    }
}
```

4. 如需监听屏幕的旋转，**不用再监听`UIDevice.orientationDidChangeNotification`通知**，而是监听该工具类提供的`ScreenRotator.orientationDidChangeNotification`通知。或者通过闭包的形式实现监听：

```swift
ScreenRotator.shard.orientationMaskDidChange = { orientationMask in 
    // 更新`FunnyButton`所属`window`的方向
    FunnyButton.orientationMask = orientationMask
}
```

5. 如果是**iPad App**，需要去`TARGETS` -> `General` -> `Deployment Info` -> 打开`Requires full screen`，方可使用代码旋转屏幕：

![ScreenRotator_4.jpg](https://github.com/Rogue24/JPCover/raw/master/ScreenRotator/ScreenRotator_4.jpg)

## API

全局使用单例`ScreenRotator.shared`调用：

1. 旋转至目标方向

```swift
func rotation(to orientation: Orientation)
```

2. 旋转至竖屏（手机头在上边）

```swift
func rotationToPortrait()
```

3. 旋转至竖屏（手机头在下边）

```swift
func rotationToPortraitUpsideDown()
```

4. 旋转至横屏（如果锁定了屏幕，则转向手机头在左边）

```swift
func rotationToLandscape()
```

5. 旋转至横屏（手机头在左边）

```swift
func rotationToLandscapeLeft()
```

6. 旋转至横屏（手机头在右边）

```swift
func rotationToLandscapeRight()
```

7. 横竖屏切换

```swift
func toggleOrientation()
```

8. 是否正在竖屏（手机头在上边）

```swift
var isPortrait: Bool
```

9. 当前屏幕方向（ScreenRotator.Orientation）

```swift
var orientation: Orientation
```

10. 是否允许转向`竖屏-手机头在下边`的方向（默认不允许）

```swift
var isAllowPortraitUpsideDown: Bool
```

11. 是否锁定屏幕方向（当控制中心禁止了竖屏锁定，为`true`则不会【随手机摆动自动改变】屏幕方向）

```swift
var isLockOrientationWhenDeviceOrientationDidChange = true 
// PS：即便锁定了（`true`）也能通过该工具类去旋转屏幕方向
```

12. 是否锁定横屏方向（当控制中心禁止了竖屏锁定，为`true`则【仅限横屏的两个方向会随手机摆动自动改变】屏幕方向）

```swift
var isLockLandscapeWhenDeviceOrientationDidChange = false 
// PS：即便锁定了（`true`）也能通过该工具类去旋转屏幕方向
```

13. <屏幕方向>发生改变的回调闭包

```swift
var orientationMaskDidChange: ((_ orientationMask: UIInterfaceOrientationMask) -> ())?
```

14. <是否锁定屏幕方向>发生改变的回调闭包

```swift
var lockOrientationWhenDeviceOrientationDidChange: ((_ isLock: Bool) -> ())?
```

15. <是否锁定横屏方向>发生改变的回调闭包

```swift
var lockLandscapeWhenDeviceOrientationDidChange: ((_ isLock: Bool) -> ())?
```

## 可监听的通知

1. <屏幕方向>发生改变的通知：

- `ScreenRotator.orientationDidChangeNotification`
    - object: `orientationMask`（UIInterfaceOrientationMask）

2. <是否锁定屏幕方向>发生改变的通知：

- `ScreenRotator.lockOrientationWhenDeviceOrientationDidChangeNotification`
    - object: `isLockOrientationWhenDeviceOrientationDidChange`（Bool）

3. <是否锁定横屏方向>发生改变的通知：

- `ScreenRotator.lockLandscapeWhenDeviceOrientationDidChangeNotification`
    - object: `isLockLandscapeWhenDeviceOrientationDidChange`（Bool）

## 兼容 OC & SwiftUI

- OC：使用专门用OC写的`JPScreenRotator`，用法和`ScreenRotator`完全一致。

- SwiftUI：可以通过`ScreenRotatorState`来更新状态。
    - 具体使用可以参考Demo中的`RotatorView`。

## Tips

当`push`或`present`一个跟当前方向不一样的新页面时，建议**先旋转**，再延时至少0.1s才打开，否则新页面的屏幕方向会错乱。例如：

```swift
let testVC = UIViewController()

// 1.先旋转
ScreenRotator.shared.rotation(to: .landscapeRight)

// 2.延时至少0.1s再打开
DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
    if let navCtr = self.navigationController {
        navCtr.pushViewController(testVC, animated: true)
    } else {
        self.present(testVC, animated: true)
    }  
}
```

## 安装

ScreenRotator 可通过[CocoaPods](http://cocoapods.org)安装，只需添加下面一行到你的podfile：

```ruby
pod 'ScreenRotator'
```
