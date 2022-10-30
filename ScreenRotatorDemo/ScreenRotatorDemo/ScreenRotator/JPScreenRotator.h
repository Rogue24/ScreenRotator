//
//  JPScreenRotator.h
//  ScreenRotatorDemo
//
//  Created by 周健平 on 2022/10/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Notification: 屏幕方向发生改变的通知
 * object: orientationMask（UIInterfaceOrientationMask）
 * userInfo: nil
 */
UIKIT_EXTERN NSNotificationName const JPScreenRotatorOrientationDidChangeNotification;

/**
 * Notification: 锁定屏幕方向发生改变的通知
 * object: isLockOrientationWhenDeviceOrientationDidChange（BOOL）
 * userInfo: nil
 */
UIKIT_EXTERN NSNotificationName const JPScreenRotatorLockOrientationWhenDeviceOrientationDidChangeNotification;

/**
 * Notification: 锁定横屏方向发生改变的通知
 * object: isLockLandscapeWhenDeviceOrientationDidChange（BOOL）
 * userInfo: nil
 */
UIKIT_EXTERN NSNotificationName const JPScreenRotatorLockLandscapeWhenDeviceOrientationDidChangeNotification;

/** 可旋转的屏幕方向 */
typedef NS_ENUM(NSUInteger, JPScreenOrientation) {
    JPScreenOrientationPortrait,        // 竖屏 手机头在上边
    JPScreenOrientationLandscapeLeft,   // 横屏 手机头在左边
    JPScreenOrientationLandscapeRight,  // 横屏 手机头在右边
};

@interface JPScreenRotator : NSObject
/** 单例 */
+ (instancetype)sharedInstance;

/** 是否正在竖屏 */
@property (nonatomic, assign, readonly) BOOL isPortrait;

/** 当前屏幕方向（JPScreenOrientation） */
@property (nonatomic, assign, readonly) JPScreenOrientation orientation;

/** 当前屏幕方向（UIInterfaceOrientationMask）  */
@property (nonatomic, assign, readonly) UIInterfaceOrientationMask orientationMask;

/** 是否锁定屏幕方向（当控制中心禁止了竖屏锁定，为`YES`则不会【随手机摆动自动改变】屏幕方向） */
@property (nonatomic, assign) BOOL isLockOrientationWhenDeviceOrientationDidChange;
// PS：即便锁定了（`YES`）也能通过该类去旋转屏幕方向

/** 是否锁定横屏方向（当控制中心禁止了竖屏锁定，为`YES`则【仅限横屏的两个方向会随手机摆动自动改变】屏幕方向） */
@property (nonatomic, assign) BOOL isLockLandscapeWhenDeviceOrientationDidChange;
// PS：即便锁定了（`YES`）也能通过该类去旋转屏幕方向

/** 屏幕方向发生改变的回调 */
@property (nonatomic, copy) void (^_Nullable orientationMaskDidChange)(UIInterfaceOrientationMask orientationMask);

/** 锁定屏幕方向发生改变的回调 */
@property (nonatomic, copy) void (^_Nullable lockOrientationWhenDeviceOrientationDidChange)(BOOL isLock);

/** 锁定横屏方向发生改变的回调 */
@property (nonatomic, copy) void (^_Nullable lockLandscapeWhenDeviceOrientationDidChange)(BOOL isLock);

/** 旋转至目标方向 */
- (void)rotationToOrientation:(JPScreenOrientation)orientation;

/** 旋转至竖屏 */
- (void)rotationToPortrait;

/** 旋转至横屏（如果锁定了屏幕，则转向手机头在左边） */
- (void)rotationToLandscape;

/** 旋转至横屏（手机头在左边） */
- (void)rotationToLandscapeLeft;

/** 旋转至横屏（手机头在右边） */
- (void)rotationToLandscapeRight;

/** 横竖屏切换 */
- (void)toggleOrientation;
@end

NS_ASSUME_NONNULL_END
 
