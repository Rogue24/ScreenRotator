//
//  MainViewController.swift
//  ScreenRotatorDemo
//
//  Created by 周健平 on 2022/10/28.
//

import UIKit
import SnapKit
import FunnyButton
import ScreenRotator

class MainViewController: BaseViewController {
    
    init() {
        super.init(portraitImgName: "IMG_6352", landscapeImgName: "IMG_6353", isPortrait: ScreenRotator.shared.isPortrait)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let btn = UIButton(type: .custom)
//        btn.addTarget(self, action: #selector(goShowVC), for: .touchUpInside)
//        view.addSubview(btn)
//        btn.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        replaceFunnyAction {
            if RotatorViewController.isShowing {
                RotatorViewController.hide()
            } else {
                RotatorViewController.show()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: view)
        
        let alertCtr = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertCtr.addAction(UIAlertAction(title: ScreenRotator.shared.isAllowPortraitUpsideDown ? "Disable PortraitUpsideDown" : "Allow PortraitUpsideDown", style: .default) { _ in
            ScreenRotator.shared.isAllowPortraitUpsideDown.toggle()
        })
        
        alertCtr.addAction(UIAlertAction(title: "Push Portrait Page", style: .default) { _ in
            TestViewController.push(from: self.navigationController!, orientation: .portrait)
        })
        alertCtr.addAction(UIAlertAction(title: "Push LandscapeLeft Page", style: .default) { _ in
            TestViewController.push(from: self.navigationController!, orientation: .landscapeLeft)
        })
        alertCtr.addAction(UIAlertAction(title: "Push LandscapeRight Page", style: .default) { _ in
            TestViewController.push(from: self.navigationController!, orientation: .landscapeRight)
        })
        alertCtr.addAction(UIAlertAction(title: "Push Video Page", style: .default) { _ in
            VideoViewController.push(from: self.navigationController!)
        })
        
        alertCtr.addAction(UIAlertAction(title: "Present Portrait Page", style: .default) { _ in
            TestViewController.present(from: self, orientation: .portrait)
        })
        alertCtr.addAction(UIAlertAction(title: "Present LandscapeLeft Page", style: .default) { _ in
            TestViewController.present(from: self, orientation: .landscapeLeft)
        })
        alertCtr.addAction(UIAlertAction(title: "Present LandscapeRight Page", style: .default) { _ in
            TestViewController.present(from: self, orientation: .landscapeRight)
        })
        alertCtr.addAction(UIAlertAction(title: "Present Video Page", style: .default) { _ in
            VideoViewController.present(from: self)
        })
        
        alertCtr.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // for iPad
        if let popover = alertCtr.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(origin: point, size: CGSize(width: 1, height: 1))
            popover.permittedArrowDirections = point.y >= view.frame.height * 0.5 ? .down : .up
        }
        
        present(alertCtr, animated: true)
    }
    
}
