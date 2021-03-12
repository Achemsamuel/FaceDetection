//
//  FaceDetectionRecordViewController.swift
//  FaceDetection
//
//  Created by Achem Samuel on 3/11/21.
//

import UIKit
import CoreML
import AVFoundation
import ARKit

final class FaceDetectionRecordViewController: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var sceneView: ARSCNView?
    private lazy var videoView: UIView = {
        let view = UIView()
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    

    private func initialSetup() {
        setupViewElements()
        checkARKitSupport()
    }
    
    private func checkARKitSupport() {
        guard ARFaceTrackingConfiguration.isSupported else {
            justRecordVideo()
            return
        }
        //setupARKit()
    }
    
    private func justRecordVideo() {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Let's say that you have an outlet to the image view called imageView
        // Create the white view
        let whiteView = UIView(frame: view.bounds)
        let maskLayer = CAShapeLayer() //create the mask layer
        
        // Set the radius to 1/3 of the screen width
        let radius : CGFloat = (view.bounds.width/3)+10

        // Create a path with the rectangle in it.
        let path = UIBezierPath(rect: view.bounds)
        // Put a circle path in the middle
        if let navigationBar = navigationController?.navigationBar {
            path.addArc(withCenter: CGPoint(x: view.center.x, y: navigationBar.frame.maxY+100), radius: radius, startAngle: 0.0, endAngle: CGFloat(2*Double.pi), clockwise: true)
        } else {
            path.addArc(withCenter: CGPoint(x: view.center.x, y: 120), radius: radius, startAngle: 0.0, endAngle: CGFloat(2*Double.pi), clockwise: true)
        }

        // Give the mask layer the path you just draw
        maskLayer.path = path.cgPath
        // Fill rule set to exclude intersected paths
        maskLayer.fillRule = .evenOdd

        // By now the mask is a rectangle with a circle cut out of it. Set the mask to the view and clip.
        whiteView.layer.mask = maskLayer
        whiteView.clipsToBounds = true

        whiteView.alpha = 0.8
        whiteView.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        videoView.addSubview(whiteView)
        
    }
    
    fileprivate func setupViewElements() {
        view.backgroundColor = .white
        view.addSubview(videoView)
        videoView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 0, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 0, left: view.leftAnchor, paddingLeft: 0, right: view.rightAnchor, paddingRight: 0, width: 0, height: 0)
        
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
    }
    
    private func setupARKit() {
        sceneView = ARSCNView(frame: videoView.frame)
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
    }
    
    @objc private func record(_ sender: UIButton) {
        ///record
        
    }
    
    
}
