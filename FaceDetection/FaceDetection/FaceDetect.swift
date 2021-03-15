//
//  FaceDetect.swift
//  FaceDetection
//
//  Created by Achem Samuel on 3/15/21.
//

import Foundation
import Vision

final class FaceDetect: NSObject {
    
    static let shared = FaceDetect()
    private var oldNoseArea = 0
    
    public func detectFace(in image: CVPixelBuffer, completion: @escaping (Bool) -> Void) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation], results.count > 0 {
                    ///detected faces ///faces.count
                    if let firstResult = results.first {
                        if let nose = firstResult.landmarks?.nose {
                            ///detect nose moving left and right with points
                            debugPrint(nose.normalizedPoints)
                        }
                        
                        if let noseCrest = firstResult.landmarks?.noseCrest {
                            ///detect nose moving left and right with points
                            debugPrint(noseCrest.normalizedPoints)
                        }
                    }
                    completion(true)
                } else {
                    ///didn't detect any faces
                    completion(false)
                }
            }
        })
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest])
    }

    deinit {
        print(#function, #fileID)
    }
}
