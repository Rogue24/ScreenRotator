//
//  BaseViewController.swift
//  ScreenRotatorDemo
//
//  Created by 周健平 on 2022/10/28.
//

import UIKit
import SnapKit

class BaseViewController: UIViewController {
    private let bgImgView = UIImageView()
    private let portraitImgName: String
    private let landscapeImgName: String
    private(set) var isPortrait: Bool = true {
        didSet {
            guard isPortrait != oldValue else { return }
            updateBgImage(animated: true)
            screenSwitched(animated: true)
        }
    }
    
    init(portraitImgName: String, landscapeImgName: String, isPortrait: Bool) {
        self.portraitImgName = portraitImgName
        self.landscapeImgName = landscapeImgName
        self.isPortrait = isPortrait
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        setupBgImageView()
        updateBgImage(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            self.isPortrait = ScreenRotator.shared.isPortrait
        }
    }
    
    func screenSwitched(animated: Bool) {}
}

private extension BaseViewController {
    func setupBgImageView() {
        bgImgView.contentMode = .scaleAspectFill
        view.insertSubview(bgImgView, at: 0)
        bgImgView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    func updateBgImage(animated: Bool) {
        let imgName = isPortrait ? portraitImgName : landscapeImgName
        guard let imgPath = Bundle.main.path(forResource: imgName, ofType: "jpg"),
              let image = UIImage(contentsOfFile: imgPath) else { return }
        if animated {
            UIView.transition(with: bgImgView, duration: 0.3, options: .transitionCrossDissolve) {}
        }
        bgImgView.image = image
    }
}
