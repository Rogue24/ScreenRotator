//
//  RotatorViewController.swift
//  ScreenRotatorDemo
//
//  Created by 周健平 on 2022/10/28.
//

import SwiftUI
import SnapKit

// 用于`UIKit`跟`SwiftUI`之间的交互
class RotatorViewState: ObservableObject {
    @Published var isShow: Bool
    var hide: (() -> Void)? = nil
    
    init(isShow: Bool = false, hide: (() -> Void)?) {
        self.isShow = isShow
        self.hide = hide
    }
}

class RotatorViewController: UIViewController {
    private static weak var shared: RotatorViewController? = nil
    private weak var blurView: UIVisualEffectView?
    private weak var rotatorViewState: RotatorViewState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupBlurView()
        setupRotatorView()
    }
    
    private func setupBlurView() {
        let blurView = UIVisualEffectView(effect: nil)
        view.addSubview(blurView)
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        self.blurView = blurView
    }
    
    private func setupRotatorView() {
        let rotatorViewState = RotatorViewState() { RotatorViewController.hide() }
        let hostingCtr = UIHostingController(rootView: RotatorView(viewState: rotatorViewState))
        addChild(hostingCtr)
        
        guard let rotatorView = hostingCtr.view else { return }
        rotatorView.backgroundColor = .clear
        view.addSubview(rotatorView)
        rotatorView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        self.rotatorViewState = rotatorViewState
    }
}

private extension RotatorViewController {
    func show() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.13) {
            self.rotatorViewState?.isShow = true
        }
        
        UIView.animate(withDuration: 0.2) {
            self.blurView?.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        }
    }
    
    func hide() {
        rotatorViewState?.isShow = false
        
        UIView.animate(withDuration: 0.2, delay: 0.13) {
            self.blurView?.effect = nil
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
}

extension RotatorViewController {
    static var isShowing: Bool { shared != nil }
    
    static func show() {
        guard !isShowing, let topVC = GetTopMostViewController() else { return }
        
        let rotatorVC = RotatorViewController()
        rotatorVC.modalPresentationStyle = .overFullScreen
        
        topVC.present(rotatorVC, animated: false) { [weak rotatorVC] in
            rotatorVC?.show()
        }
        
        shared = rotatorVC
    }
    
    static func hide() { shared?.hide() }
}
