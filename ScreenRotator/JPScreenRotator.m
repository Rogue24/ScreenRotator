//
//  JPScreenRotator.m
//  ScreenRotatorDemo
//
//  Created by 周健平 on 2022/10/28.
//

#import "JPScreenRotator.h"

NSNotificationName const JPScreenRotatorOrientationDidChangeNotification = @"JPScreenRotatorOrientationDidChangeNotification";
NSNotificationName const JPScreenRotatorLockOrientationWhenDeviceOrientationDidChangeNotification = @"JPScreenRotatorLockOrientationWhenDeviceOrientationDidChangeNotification";
NSNotificationName const JPScreenRotatorLockLandscapeWhenDeviceOrientationDidChangeNotification = @"JPScreenRotatorLockLandscapeWhenDeviceOrientationDidChangeNotification";

static inline UIDeviceOrientation JPConvertInterfaceOrientationMaskToDeviceOrientation(UIInterfaceOrientationMask orientationMask) {
    switch (orientationMask) {
        case UIInterfaceOrientationMaskLandscapeLeft:
            return UIDeviceOrientationLandscapeRight;
        case UIInterfaceOrientationMaskLandscapeRight:
            return UIDeviceOrientationLandscapeLeft;
        case UIInterfaceOrientationMaskLandscape:
            return UIDeviceOrientationLandscapeLeft;
        default:
            return UIDeviceOrientationPortrait;
    }
}

static inline UIInterfaceOrientationMask JPConvertDeviceOrientationToInterfaceOrientationMask(UIDeviceOrientation orientation) {
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
            return UIInterfaceOrientationMaskLandscapeRight;
        case UIDeviceOrientationLandscapeRight:
            return UIInterfaceOrientationMaskLandscapeLeft;
        default:
            return UIInterfaceOrientationMaskPortrait;
    }
}

@implementation JPScreenRotator
{
    BOOL _isEnabled;
    UIInterfaceOrientationMask _orientationMask;
}

#pragma mark - 单例

static JPScreenRotator *sharedInstance_;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance_ = [super allocWithZone:zone];
    });
    return sharedInstance_;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance_ = [[JPScreenRotator alloc] init];
    });
    return sharedInstance_;
}

- (id)copyWithZone:(NSZone *)zone {
    return sharedInstance_;
}

#pragma mark - 生命周期

- (instancetype)init {
    if (self = [super init]) {
        _isEnabled = YES;
        _orientationMask = UIInterfaceOrientationMaskPortrait;
        _isLockOrientationWhenDeviceOrientationDidChange = YES;
        _isLockLandscapeWhenDeviceOrientationDidChange = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    return self;
}

- (void)dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - setter

- (void)setOrientationMask:(UIInterfaceOrientationMask)orientationMask {
    if (_orientationMask == orientationMask) return;
    _orientationMask = orientationMask;
    [self __publishOrientationMaskDidChange];
}

- (void)setIsLockOrientationWhenDeviceOrientationDidChange:(BOOL)isLockOrientationWhenDeviceOrientationDidChange {
    if (_isLockOrientationWhenDeviceOrientationDidChange == isLockOrientationWhenDeviceOrientationDidChange) return;
    _isLockOrientationWhenDeviceOrientationDidChange = isLockOrientationWhenDeviceOrientationDidChange;
    [self __publishLockOrientationWhenDeviceOrientationDidChange];
}

- (void)setIsLockLandscapeWhenDeviceOrientationDidChange:(BOOL)isLockLandscapeWhenDeviceOrientationDidChange {
    if (_isLockLandscapeWhenDeviceOrientationDidChange == isLockLandscapeWhenDeviceOrientationDidChange) return;
    _isLockLandscapeWhenDeviceOrientationDidChange = isLockLandscapeWhenDeviceOrientationDidChange;
    [self __publishLockLandscapeWhenDeviceOrientationDidChange];
}

#pragma mark - getter

- (BOOL)isPortrait {
    return _orientationMask == UIInterfaceOrientationMaskPortrait;
}

- (JPScreenOrientation)orientation {
    switch (_orientationMask) {
        case UIInterfaceOrientationMaskLandscapeLeft:
            return JPScreenOrientationLandscapeRight;
        case UIInterfaceOrientationMaskLandscapeRight:
            return JPScreenOrientationLandscapeLeft;
        case UIInterfaceOrientationMaskLandscape:
        {
            UIDeviceOrientation deviceOrientation = UIDevice.currentDevice.orientation;
            switch (deviceOrientation) {
                case UIDeviceOrientationLandscapeLeft:
                    return JPScreenOrientationLandscapeLeft;
                case UIDeviceOrientationLandscapeRight:
                    return JPScreenOrientationLandscapeRight;
                default:
                    return JPScreenOrientationPortrait;
            }
        }
        default:
            return JPScreenOrientationPortrait;
    }
}

- (UIInterfaceOrientationMask)orientationMask {
    return _orientationMask;
}

#pragma mark - 监听通知

// 不活跃了，也就是进后台了
- (void)__willResignActive {
    _isEnabled = NO;
}

// 活跃了，也就是从后台回来了
- (void)__didBecomeActive {
    _isEnabled = YES;
}

// 设备方向发生改变
- (void)__deviceOrientationDidChange {
    if (!_isEnabled) return;
    if (_isLockOrientationWhenDeviceOrientationDidChange) return;

    UIDeviceOrientation deviceOrientation = UIDevice.currentDevice.orientation;
    if (deviceOrientation == UIDeviceOrientationUnknown ||
        deviceOrientation == UIDeviceOrientationPortraitUpsideDown ||
        deviceOrientation == UIDeviceOrientationFaceUp ||
        deviceOrientation == UIDeviceOrientationFaceDown) return;
    
    if (_isLockLandscapeWhenDeviceOrientationDidChange && !UIDeviceOrientationIsLandscape(deviceOrientation)) return;
    
    UIInterfaceOrientationMask orientationMask = JPConvertDeviceOrientationToInterfaceOrientationMask(deviceOrientation);
    [self __rotationToOrientationMask:orientationMask];
}

#pragma mark - 发布通知
- (void)__publishOrientationMaskDidChange {
    !self.orientationMaskDidChange ? : self.orientationMaskDidChange(_orientationMask);
    [[NSNotificationCenter defaultCenter] postNotificationName:JPScreenRotatorOrientationDidChangeNotification object:@(_orientationMask)];
}
    
- (void)__publishLockOrientationWhenDeviceOrientationDidChange {
    !self.lockOrientationWhenDeviceOrientationDidChange ? : self.lockOrientationWhenDeviceOrientationDidChange(_isLockOrientationWhenDeviceOrientationDidChange);
    [[NSNotificationCenter defaultCenter] postNotificationName:JPScreenRotatorLockOrientationWhenDeviceOrientationDidChangeNotification object:@(_isLockOrientationWhenDeviceOrientationDidChange)];
}
    
- (void)__publishLockLandscapeWhenDeviceOrientationDidChange {
    !self.lockLandscapeWhenDeviceOrientationDidChange ? : self.lockLandscapeWhenDeviceOrientationDidChange(_isLockLandscapeWhenDeviceOrientationDidChange);
    [[NSNotificationCenter defaultCenter] postNotificationName:JPScreenRotatorLockLandscapeWhenDeviceOrientationDidChangeNotification object:@(_isLockLandscapeWhenDeviceOrientationDidChange)];
}

#pragma mark - 私有方法

- (void)__rotationToOrientationMask:(UIInterfaceOrientationMask)orientationMask {
    if (!_isEnabled) return;
    if (_orientationMask == orientationMask) return;
    
    // 更新并广播屏幕方向
    self.orientationMask = orientationMask;
    
    // 控制横竖屏
    if (@available(iOS 16.0, *)) {
        // `iOS16`由于不能再设置`UIDevice.orientation`来控制横竖屏了，所以`UIDeviceOrientationDidChangeNotification`将由系统自动发出，
        // 即手机的摆动就会自动收到通知，不能自己控制，因此不能监听该通知来适配UI，
        // 重写`UIViewController`的`-viewWillTransitionToSize:withTransitionCoordinator:`方法来监听屏幕的旋转并适配UI。
        UIWindowSceneGeometryPreferencesIOS *geometryPreferences = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:orientationMask];
        NSArray *connectedScenes = [UIApplication sharedApplication].connectedScenes.allObjects;
        for (UIScene *scene in connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class]) continue;
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            // 一般来说app只有一个`windowScene`，而`windowScene`内可能有多个`window`，
            // 例如Demo中至少有两个`window`：第一个是app主体的`window`，第二个则是`FunnyButton`所在的`window`，
            // 所以需要遍历全部`window`进行旋转，保证全部`window`都能保持一致的屏幕方向。
            
            // `iOS16`之后`attemptRotationToDeviceOrientation`建议不再使用（虽然还起效），
            // 而是调用`setNeedsUpdateOfSupportedInterfaceOrientations`进行屏幕旋转。
            for (UIWindow *window in windowScene.windows) {
                // 由于Demo中只用到`rootViewController`控制屏幕方向，所以只对`rootViewController`调用即可。
                [window.rootViewController setNeedsUpdateOfSupportedInterfaceOrientations];
                // 若需要全部控制器都执行`setNeedsUpdateOfSupportedInterfaceOrientations`，可调用该方法：
                // [JPScreenRotator __setNeedsUpdateOfSupportedInterfaceOrientationsWithCurrentVC:window.rootViewController presentedVC:nil];
            }
            
            //【注意】要在全部`window`调用`requestGeometryUpdate`之前，先对`vc`调用`attemptRotationToDeviceOrientation`，
            // 否则会报错（虽然对屏幕旋转没影响）。
            for (UIWindow *window in windowScene.windows) {
                [window.windowScene requestGeometryUpdateWithPreferences:geometryPreferences errorHandler:^(NSError * _Nonnull error) {
                    NSLog(@"jpjpjp 强制旋转错误: %@", error);
                }];
            }
        }
    } else {
        // `iOS16`之前调用`attemptRotationToDeviceOrientation`屏幕才会旋转。
        //【注意】要在确定改变的方向【设置之后】才调用，否则会旋转到【设置之前】的方向
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [UIViewController attemptRotationToDeviceOrientation];
#pragma clang diagnostic pop
        
        // `iOS16`之前修改"orientation"后会直接影响`UIDevice.currentDevice.orientation`；
        // `iOS16`之后不能再通过设置`UIDevice.orientation`来控制横竖屏了，修改"orientation"无效。
        UIDevice *currentDevice = UIDevice.currentDevice;
        UIDeviceOrientation deviceOrientation = JPConvertInterfaceOrientationMaskToDeviceOrientation(orientationMask);
        [currentDevice setValue:@(deviceOrientation) forKeyPath:@"orientation"];
    }
}

+ (void)__setNeedsUpdateOfSupportedInterfaceOrientationsWithCurrentVC:(UIViewController *)currentVC presentedVC:(UIViewController *)presentedVC {
    if (@available(iOS 16.0, *)) [currentVC setNeedsUpdateOfSupportedInterfaceOrientations];
    
    UIViewController *currentPresentedVC = currentVC.presentedViewController;
    
    if (currentPresentedVC && currentPresentedVC != presentedVC) {
        [self __setNeedsUpdateOfSupportedInterfaceOrientationsWithCurrentVC:currentPresentedVC presentedVC:nil];
    }
    
    for (UIViewController *childVC in currentVC.childViewControllers) {
        [self __setNeedsUpdateOfSupportedInterfaceOrientationsWithCurrentVC:childVC presentedVC:currentPresentedVC];
    }
}

#pragma mark - 公开方法

- (void)rotationToOrientation:(JPScreenOrientation)orientation {
    if (!_isEnabled) return;
    
    UIInterfaceOrientationMask orientationMask;
    switch (orientation) {
        case JPScreenOrientationLandscapeLeft:
            orientationMask = UIInterfaceOrientationMaskLandscapeRight;
            break;
        case JPScreenOrientationLandscapeRight:
            orientationMask = UIInterfaceOrientationMaskLandscapeLeft;
            break;
        default:
            orientationMask = UIInterfaceOrientationMaskPortrait;
            break;
    }
    
    [self __rotationToOrientationMask:orientationMask];
}

- (void)rotationToPortrait {
    [self __rotationToOrientationMask:UIInterfaceOrientationMaskPortrait];
}

- (void)rotationToLandscape {
    if (!_isEnabled) return;
    
    UIInterfaceOrientationMask orientationMask = JPConvertDeviceOrientationToInterfaceOrientationMask(UIDevice.currentDevice.orientation);
    if (orientationMask == UIInterfaceOrientationMaskPortrait) {
        orientationMask = UIInterfaceOrientationMaskLandscapeRight;
    }
    
    [self __rotationToOrientationMask:orientationMask];
}

- (void)rotationToLandscapeLeft {
    [self __rotationToOrientationMask:UIInterfaceOrientationMaskLandscapeRight];
}

- (void)rotationToLandscapeRight {
    [self __rotationToOrientationMask:UIInterfaceOrientationMaskLandscapeLeft];
}

- (void)toggleOrientation {
    if (!_isEnabled) return;
    
    UIInterfaceOrientationMask orientationMask = JPConvertDeviceOrientationToInterfaceOrientationMask(UIDevice.currentDevice.orientation);
    if (orientationMask == _orientationMask) {
        if (_orientationMask == UIInterfaceOrientationMaskPortrait) {
            orientationMask = UIInterfaceOrientationMaskLandscapeRight;
        } else {
            orientationMask = UIInterfaceOrientationMaskPortrait;
        }
    }
    
    [self __rotationToOrientationMask:orientationMask];
}

@end
