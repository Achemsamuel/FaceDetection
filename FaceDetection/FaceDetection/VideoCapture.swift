//
//  VideoCapture.swift
//  FaceDetection
//
//  Created by Achem Samuel on 3/15/21.
//

import UIKit
import AVFoundation
import CoreVideo

public protocol VideoCaptureDelegate: class {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame: CVPixelBuffer?, timestamp: CMTime)
    func videoFileOutPut(_ fileUrl: URL)
}

public class VideoCapture: NSObject {
    public var previewLayer: AVCaptureVideoPreviewLayer?
    public weak var delegate: VideoCaptureDelegate?
    public var fps = 15
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    private var _adapter: AVAssetWriterInputPixelBufferAdaptor?
    private var cameraDelegateRemoved = false
    
    let captureSession = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    let movieOutput = AVCaptureMovieFileOutput()
    let queue = DispatchQueue(label: "videoQueue")
    
    var lastTimestamp = CMTime()
    private var time: Double = 0
    private let fileName = "\(UUID().uuidString)_kuda_kyc.mp4"
    
    private enum CaptureState {
        case idle, start, capturing, end
    }
    private var captureState = CaptureState.idle
    
    public func setUp(sessionPreset: AVCaptureSession.Preset = .vga640x480,
                      completion: @escaping (Bool) -> Void) {
        self.setUpCamera(sessionPreset: sessionPreset, completion: { success in
            completion(success)
        })
    }
    
    func setUpCamera(sessionPreset: AVCaptureSession.Preset, completion: @escaping (_ success: Bool) -> Void) {
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = sessionPreset
        
        guard let captureDevice = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
                mediaType: .video,
                position: .front).devices.first else {
            print("Error: no video devices available")
            return
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Error: could not create AVCaptureDeviceInput")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        self.previewLayer = previewLayer
        
        let settings: [String : Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA),
        ]
        
        videoOutput.videoSettings = settings
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        if let connection = videoOutput.connection(with: AVMediaType.video), connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = true
            }
        }
        
        captureSession.commitConfiguration()
        
        let success = true
        completion(success)
    }
    
    public func start() {
        if !captureSession.isRunning {
            if cameraDelegateRemoved {
                videoOutput.setSampleBufferDelegate(self, queue: queue)
                cameraDelegateRemoved = false
            }
            captureSession.startRunning()
        }
    }
    
    public func forceStopRecordingBecauseUserMovedOutOfScreen() {
        captureState = .idle
    }
    
    public func stop() {
        if captureSession.isRunning {
            captureSession.stopRunning()
            captureState = .end
        }
    }
    
    public func startRecording() {
        switch captureState {
        case .idle:
            captureState = .start
        default:
            captureState = .idle
        }
    }
    
    public func stopRecording() {
        switch captureState {
        case .capturing:
            captureState = .end
        default:
            captureState = .idle
        }
    }
    
    public func reset() {
        videoOutput.setSampleBufferDelegate(nil, queue: nil)
        stopRecording()
        stop()
        cameraDelegateRemoved = true
    }
    
    deinit {
        videoOutput.setSampleBufferDelegate(nil, queue: nil)
        stopRecording()
        stop()
        print(#function, #fileID)
    }
}

extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        switch captureState {
        case .start:
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            guard let fileUrl = paths.first?.appendingPathComponent(fileName) else {break}
            try? FileManager.default.removeItem(at: fileUrl)
            
            let writer = try! AVAssetWriter(outputURL: fileUrl, fileType: .mp4)
            let settings = videoOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mp4)
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings) // [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 1920, AVVideoHeightKey: 1080])
            input.mediaTimeScale = CMTimeScale(bitPattern: 600)
            input.expectsMediaDataInRealTime = true
            input.transform = CGAffineTransform(rotationAngle: .pi/3)
            let adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
            if writer.canAdd(input) {
                writer.add(input)
            }
            writer.startWriting()
            writer.startSession(atSourceTime: .zero)
            assetWriter = writer
            assetWriterInput = input
            _adapter = adapter
            captureState = .capturing
            time = timestamp.seconds
        case .capturing:
            if assetWriterInput?.isReadyForMoreMediaData == true {
                let _time = CMTime(seconds: timestamp.seconds - time, preferredTimescale: CMTimeScale(600))
                if let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                    _adapter?.append(buffer, withPresentationTime: _time)
                }
            }
        case .end:
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            guard assetWriterInput?.isReadyForMoreMediaData == true, assetWriter?.status != .failed, let fileUrl = paths.first?.appendingPathComponent(fileName) else {
                break
            }
            assetWriterInput?.markAsFinished()
            assetWriter?.finishWriting { [weak self] in
                self?.captureState = .idle
                self?.assetWriter = nil
                self?.assetWriterInput = nil
            }
            delegate?.videoFileOutPut(fileUrl)
            captureSession.stopRunning()
            videoOutput.setSampleBufferDelegate(nil, queue: nil)
        default:
            break
        }
        let buffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        delegate?.videoCapture(self, didCaptureVideoFrame: buffer, timestamp: timestamp)
    }
}

extension VideoCapture: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
    }
}


