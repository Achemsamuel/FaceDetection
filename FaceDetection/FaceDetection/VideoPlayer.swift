//
//  VideoPlayer.swift
//  FaceDetection
//
//  Created by Achem Samuel on 3/15/21.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private lazy var cancel: UIButton = {
       let button = UIButton()
        button.setImage(.remove, for: .normal)
        button.addTarget(self, action: #selector(removeViewFromSuperView), for: .touchUpInside)
        return button
    }()
    
    init(withFrame frame: CGRect, videoURLString: String) {
        super.init(frame: frame)
        backgroundColor = .black
        setupVideoPlayer(with: videoURLString)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupVideoPlayer(with path: String) {
        addPlayer(with: path)
        player?.play()

    }
    
    private func addPlayer(with urlPath: String) {
        let videoURL = URL(fileURLWithPath: urlPath)
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        
        if let playerLayer = playerLayer {
            self.layer.addSublayer(playerLayer)
            playerLayer.frame = self.bounds
        }
    }
    
    @objc private func removeViewFromSuperView() {
        removeFromSuperview()
    }
    
}

final class VideoPlayerViewController: UIViewController {
    
    private var path: String = ""
    init(path: String) {
        super.init(nibName: nil, bundle: nil)
        self.path = path
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupPlayer(path)
    }
    
    private func setupPlayer(_ path: String) {
        let playerRect = view.bounds
        let videoPlayer = VideoPlayerView(withFrame: playerRect, videoURLString: path)
        view.addSubview(videoPlayer)
    }
}
