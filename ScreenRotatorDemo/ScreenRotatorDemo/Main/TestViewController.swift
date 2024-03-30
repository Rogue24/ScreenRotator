//
//  TestViewController.swift
//  ScreenRotatorDemo
//
//  Created by 周健平 on 2022/10/28.
//

import UIKit
import SnapKit
import ScreenRotator

class TestViewController: BaseViewController {
    
    private let originOrientation: ScreenRotator.Orientation?
    
    init(orientation: ScreenRotator.Orientation, originOrientation: ScreenRotator.Orientation?) {
        self.originOrientation = originOrientation
        super.init(portraitImgName: "IMG_6350", landscapeImgName: "IMG_6351", isPortrait: orientation == .portrait)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    @objc func close() {
        view.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Self.willClose(originOrientation)) {
            if let navCtr = self.navigationController {
                navCtr.popViewController(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }
    }
    
}

extension TestViewController {
    static func push(from navCtr: UINavigationController, orientation: ScreenRotator.Orientation) {
        let testVC = TestViewController(orientation: orientation, originOrientation: ScreenRotator.shared.orientation)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + willShow(orientation)) {
            navCtr.pushViewController(testVC, animated: true)
        }
    }
    
    static func present(from vc: UIViewController, orientation: ScreenRotator.Orientation) {
        let testVC = TestViewController(orientation: orientation, originOrientation: ScreenRotator.shared.orientation)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + willShow(orientation)) {
            vc.present(testVC, animated: true)
        }
    }
    
    private static func willShow(_ orientation: ScreenRotator.Orientation) -> Double {
        let isLandscape = orientation != .portrait
        ScreenRotator.shared.isLockOrientationWhenDeviceOrientationDidChange = !isLandscape
        ScreenRotator.shared.isLockLandscapeWhenDeviceOrientationDidChange = isLandscape
        guard orientation != ScreenRotator.shared.orientation else { return 0 }
        ScreenRotator.shared.rotation(to: orientation)
        return 0.1
    }
    
    private static func willClose(_ orientation: ScreenRotator.Orientation?) -> Double {
        ScreenRotator.shared.isLockOrientationWhenDeviceOrientationDidChange = false
        ScreenRotator.shared.isLockLandscapeWhenDeviceOrientationDidChange = false
        guard let orientation = orientation, orientation != ScreenRotator.shared.orientation else { return 0 }
        ScreenRotator.shared.rotation(to: orientation)
        return 0.1
    }
}
