//
//  VideoViewController.swift
//  ScreenRotatorDemo
//
//  Created by 周健平 on 2022/10/28.
//

import UIKit
import AVKit
import SnapKit

class PlayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    public var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}

class VideoViewController: BaseViewController {
    
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
   
    let asset = AVURLAsset(url: URL(fileURLWithPath: Bundle.main.path(forResource: "ali", ofType: "mp4")!))
    
    lazy var player: AVPlayer = AVPlayer(playerItem: AVPlayerItem(asset: asset))
    
    lazy var playerView: PlayerView = {
        let playerView = PlayerView()
        playerView.playerLayer.player = player
        playerView.playerLayer.videoGravity = .resizeAspect
        return playerView
    }()
    
    class MyButton: UIButton {
        override var isHighlighted: Bool {
            set {}
            get { super.isHighlighted }
        }
        
        init() {
            super.init(frame: .zero)
            tintColor = .white
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 5)
            layer.shadowOpacity = 0.5
            layer.shadowRadius = 5
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    lazy var closeBtn: MyButton = {
        let btn = MyButton()
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        return btn
    }()
    
    lazy var extendBtn: MyButton = {
        let btn = MyButton()
        btn.setImage(UIImage(systemName: "arrow.up.backward.and.arrow.down.forward"), for: .normal)
        btn.setImage(UIImage(systemName: "arrow.down.forward.and.arrow.up.backward"), for: .selected)
        btn.addTarget(self, action: #selector(extend), for: .touchUpInside)
        return btn
    }()
    
    init() {
        super.init(portraitImgName: "IMG_6350", landscapeImgName: "IMG_6351", isPortrait: true)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem!)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: ScreenRotator.orientationDidChangeNotification, object: nil)
        
        contentView.addSubview(playerView)
        contentView.addSubview(closeBtn)
        contentView.addSubview(extendBtn)
        view.addSubview(contentView)
        
        screenSwitched(animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
    }
    
    override func screenSwitched(animated: Bool) {
        let safeAreaInsets = view.window?.safeAreaInsets ?? .zero
        
        let videoSize = asset.tracks(withMediaType: .video).first?.naturalSize ?? CGSize(width: 1, height: 1)
        let playerViewSize: CGSize
        if ScreenRotator.shared.isPortrait {
            let w = UIScreen.main.bounds.width
            let h = w * (videoSize.height / videoSize.width)
            playerViewSize = CGSize(width: w, height: h)
        } else {
            let minW = UIScreen.main.bounds.width - safeAreaInsets.left - safeAreaInsets.right
            var h = UIScreen.main.bounds.height
            var w = h * (videoSize.width / videoSize.height)
            if w > minW {
                w = minW
                h = w * (videoSize.height / videoSize.width)
            }
            playerViewSize = CGSize(width: w, height: h)
        }
        
        contentView.snp.remakeConstraints { make in
            make.width.equalTo(view.snp.width)
            make.height.equalTo(isPortrait ? view.snp.width : view.snp.height)
            make.center.equalToSuperview()
        }
        
        playerView.snp.remakeConstraints { make in
            make.size.equalTo(playerViewSize)
            make.center.equalToSuperview()
        }
        
        closeBtn.snp.remakeConstraints { make in
            make.width.height.equalTo(44)
            make.left.equalTo(playerView)
            make.top.equalToSuperview()
        }
        
        extendBtn.snp.remakeConstraints { make in
            make.width.height.equalTo(44)
            make.left.equalTo(closeBtn.snp.right).offset(5)
            make.centerY.equalTo(closeBtn)
        }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else {
            view.layoutIfNeeded()
        }
    }
    
    @objc func playerItemDidPlayToEnd() {
        player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        player.play()
    }
    
    @objc func orientationDidChange() {
        extendBtn.isSelected = !ScreenRotator.shared.isPortrait
    }
    
    @objc func close() {
        if let navCtr = navigationController {
            navCtr.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc func extend() {
        ScreenRotator.shared.toggleOrientation()
    }
    
}

extension VideoViewController {
    static func push(from navCtr: UINavigationController) {
        let videoVC = VideoViewController()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + willShow()) {
            navCtr.pushViewController(videoVC, animated: true)
        }
    }
    
    static func present(from vc: UIViewController) {
        let videoVC = VideoViewController()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + willShow()) {
            vc.present(videoVC, animated: true)
        }
    }
    
    private static func willShow() -> Double {
        ScreenRotator.shared.isLockOrientationWhenDeviceOrientationDidChange = false
        ScreenRotator.shared.isLockLandscapeWhenDeviceOrientationDidChange = false
        guard ScreenRotator.shared.orientation != .portrait else { return 0 }
        ScreenRotator.shared.rotationToPortrait()
        return 0.1
    }
}
