//
//  VideoRecordViewController.swift
//  FaceDetection
//
//  Created by Achem Samuel on 3/15/21.
//

import UIKit
import CoreML
import AVFoundation
import ARKit

final class VideoRecordViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var videoCapture: VideoCapture?
    private let semaphore = DispatchSemaphore(value: 1)
    private var videoPlayer: VideoPlayerView?
    private var sessionRunning = false
    private var recordingVideo = false
    
    private var sceneView: ARSCNView?
    private lazy var videoView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var recordTopText: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 17)
        label.text = "Record a video"
        return label
    }()
    
    private lazy var recordDescritionText: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Make two circles with your head"
        return label
    }()
    
    private lazy var recordButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "record"), for: .normal)
        button.addTarget(self, action: #selector(record), for: .touchUpInside)
        return button
    }()
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.95)
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 50)
        label.text = "\(seconds)"
        return label
    }()
    
    private var backView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    private var textLayer: CATextLayer = {
        let textLayer = CATextLayer()
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = .center
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = UIFont.systemFont(ofSize: 13)  //CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        textLayer.fontSize = 13.0
        textLayer.opacity = 1
        
        return textLayer
    }()
    
    private lazy var noFacesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    private var noFacesLabelAlreadyAdded = false
    
    private var timer: Timer?
    private var seconds = 5
    private var runCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    private func initialSetup() {
        setupViewElements()
        checkARKitSupport()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        videoCapture?.reset()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoCapture?.start()
    }
    
    private func checkARKitSupport() {
        setupARKit()
        guard ARFaceTrackingConfiguration.isSupported else {
            justRecordVideo()
            return
        }
    }
    
    private func runTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                
                self.seconds -= 1
                self.runCount += 1

                if self.runCount == 5 {
                    timer.invalidate()
                    self.seconds = 5
                    self.runCount = 0
                    
                    self.videoCapture?.stopRecording()
                    self.recordingVideo = false
                    self.timerLabel.isHidden = true
                    self.recordButton.isHidden = false
                }
                self.timerLabel.text = "\(self.seconds)"
            }
        }
    }
    
    private func justRecordVideo() {}
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        backView.frame = view.bounds
        let maskLayer = CAShapeLayer()
        
        let radius : CGFloat = (view.bounds.width/3)+10
        
        let path = UIBezierPath(rect: view.bounds)
        // Put a circle path in the middle
        if let navigationBar = navigationController?.navigationBar {
            path.addArc(withCenter: CGPoint(x: view.center.x, y: navigationBar.frame.maxY+100), radius: radius, startAngle: 0.0, endAngle: CGFloat(2*Double.pi), clockwise: true)
        } else {
            path.addArc(withCenter: CGPoint(x: view.center.x, y: 120), radius: radius, startAngle: 0.0, endAngle: CGFloat(2*Double.pi), clockwise: true)
        }
        
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        
        backView.layer.mask = maskLayer
        backView.clipsToBounds = true
        
        videoView.addSubview(backView)
        videoCapture?.previewLayer?.frame = videoView.frame
    }
    
    
    fileprivate func setupViewElements() {
        view.backgroundColor = .white
        setupCamera()
        view.addSubview(videoView)
        videoView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: -2, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 0, left: view.leftAnchor, paddingLeft: 0, right: view.rightAnchor, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(bottomView)
        bottomView.anchor(top: nil, paddingTop: 0, bottom: view.bottomAnchor, paddingBottom: 0, left: view.leftAnchor, paddingLeft: 0, right: view.rightAnchor, paddingRight: 0, width: 0, height: 205)
        
        bottomView.addSubview(recordTopText)
        bottomView.addSubview(recordDescritionText)
        bottomView.addSubview(recordButton)
        
        recordTopText.anchor(top: bottomView.topAnchor, paddingTop: 20, bottom: nil, paddingBottom: 0, left: bottomView.leftAnchor, paddingLeft: 20, right: bottomView.rightAnchor, paddingRight: 20, width: 0, height: 25)
        
        recordDescritionText.anchor(top: recordTopText.bottomAnchor, paddingTop: 10, bottom: nil, paddingBottom: 0, left: recordTopText.leftAnchor, paddingLeft: 0, right: recordTopText.rightAnchor, paddingRight: 0, width: 0, height: 0)
        
        recordButton.anchor(top: nil, paddingTop: 0, bottom: bottomView.bottomAnchor, paddingBottom: 30, left: nil, paddingLeft: 0, right: nil, paddingRight: 0, width: 65, height: 65)
        recordButton.topAnchor.constraint(greaterThanOrEqualTo: recordDescritionText.bottomAnchor, constant: 15).isActive = true
        recordButton.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor).isActive = true
        
        bottomView.addSubview(timerLabel)
        timerLabel.anchor(top: recordButton.topAnchor, paddingTop: 0, bottom: recordButton.bottomAnchor, paddingBottom: 0, left: recordButton.leftAnchor, paddingLeft: 0, right: recordButton.rightAnchor, paddingRight: 0, width: 0, height: 0)
        timerLabel.isHidden = true
        
    }
    
    private func setupARKit() {
//        sceneView = ARSCNView(frame: view.frame)
//        let configuration = ARFaceTrackingConfiguration()
//        configuration.isLightEstimationEnabled = true
//
//        guard let sceneView = sceneView else {return}
//        sceneView.delegate = self
//        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    fileprivate func setupCamera() {
        videoCapture = VideoCapture()
        guard let videoCapture = videoCapture else {return}
        
        videoCapture.delegate = self
        videoCapture.fps = 30
        videoCapture.setUpCamera(sessionPreset: .high) { [weak self] (success) in
            guard let self = self else {return}
            
            if success {
                if let previewLayer = self.videoCapture?.previewLayer {
                    self.view.layer.addSublayer(previewLayer)
                    self.videoCapture?.previewLayer?.frame = self.view.frame
                }
                
                self.videoCapture?.start()
            }
        }
    }
    
    @objc private func record(_ sender: UIButton) {
        ///record
        if recordingVideo {
            videoCapture?.stopRecording()
            recordingVideo = false
            timerLabel.isHidden = true
            timerLabel.stopBreathing()
            recordButton.isHidden = false
        } else {
            videoCapture?.startRecording()
            recordingVideo = true
            timerLabel.isHidden = false
            timerLabel.breathe()
            recordButton.isHidden = true
            runTimer()
        }
    }
    
    deinit {
        videoCapture?.stop()
        print(#function, #fileID)
    }
}

extension VideoRecordViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame: CVPixelBuffer?, timestamp: CMTime) {
        if let buffer = didCaptureVideoFrame {
            //detect(in: buffer)
            FaceDetect.shared.detectFace(in: buffer) { [weak self] success in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    if success {
                        self.textLayer.removeFromSuperlayer()
                        self.recordButton.alpha = 1
                        self.recordButton.isUserInteractionEnabled = true
                        self.noFacesLabel.removeFromSuperview()
                        self.noFacesLabelAlreadyAdded = false
                    } else {
                        let text = """
                        We can't see your face 😔 \n
                        Please, place your face within the circle
                        """
                        let heightOfString = text.heightOfString(usingFont: UIFont.systemFont(ofSize: 15))*2
                        
                        if !self.noFacesLabelAlreadyAdded {
                            self.noFacesLabel.text = text
                            self.noFacesLabel.frame = CGRect(x: 20, y: self.bottomView.frame.minY-(heightOfString), width: self.backView.frame.width-40, height: heightOfString)
                            self.backView.addSubview(self.noFacesLabel)
                        }
                        
                        self.recordButton.alpha = 0.5
                        self.recordButton.isUserInteractionEnabled = false
                    }
                }
            }
        }
    }
    
    ///old implementation for face detetction but this is prone to errors with false positives according to Apple
    func detect(in image: CVPixelBuffer) {
        var detectText = ""
        //Get image from image view
        let ciImage = CIImage(cvImageBuffer: image)
        
        //Set up the detecor
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)!
        
        let faces = faceDetector.features(in: ciImage)
        
        if let face = faces.first as? CIFaceFeature {
            detectText = detectText + "Found face at \(face.bounds)"
            if face.hasLeftEyePosition {}
            
            if face.hasRightEyePosition {}
            
            if face.hasMouthPosition {}
            DispatchQueue.main.async { [weak self] in
                self?.recordButton.alpha = 1
                self?.recordButton.isUserInteractionEnabled = true
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.recordButton.alpha = 0.5
                self?.recordButton.isUserInteractionEnabled = false
            }
        }
    }
    
    func videoFileOutPut(_ fileUrl: URL) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.navigationController?.pushViewController(VideoPlayerViewController(path: fileUrl.path), animated: true)
        }
    }
}

extension VideoRecordViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let device = sceneView?.device else {
            return nil
        }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let node = SCNNode(geometry: faceGeometry)
        node.geometry?.firstMaterial?.fillMode = .lines
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
            return
        }
        faceGeometry.update(from: faceAnchor.geometry)
    }
}
