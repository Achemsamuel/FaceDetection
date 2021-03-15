//
//  UIView+Extension.swift
//  FaceDetection
//
//  Created by Achem Samuel on 3/12/21.
//

import UIKit

extension UIView {
    
    func addVideoOverlay(frame: CGRect,
                       xOffset: CGFloat,
                       yOffset: CGFloat,
                       radius: CGFloat) {
        // Step 1
        let overlayView = UIView(frame: frame)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        // Step 2
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: xOffset, y: yOffset),
                    radius: radius,
                    startAngle: 0.0,
                    endAngle: 2.0 * .pi,
                    clockwise: false)
        path.addRect(CGRect(origin: .zero, size: overlayView.frame.size))
        // Step 3
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        // For Swift 4.0
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        // For Swift 4.2
        maskLayer.fillRule = .evenOdd
        // Step 4
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true

        addSubview(overlayView)
    }
    
    
    
//    func addVideoOverlay(frame : CGRect)
//    {
//        let overlayView = UIView(frame: frame)
//        overlayView.alpha = 0.6
//        overlayView.backgroundColor = UIColor.black
//        addSubview(overlayView)
//
//        let maskLayer = CAShapeLayer()
//
//        // Create a path with the rectangle in it.
//        let path = CGMutablePath()
//
//        let radius : CGFloat = 50.0
//        let xOffset : CGFloat = 10
//        let yOffset : CGFloat = 10
//
//        path.addArc(center: CGPoint(x: xOffset, y: yOffset), radius: radius, startAngle: 0.0, endAngle: 2 * 3.14, clockwise: false)
//        path.addRect(CGRect(x: 0, y: 0, width: overlayView.frame.width, height: overlayView.frame.height))
//
//        maskLayer.backgroundColor = UIColor.black.cgColor
//
//        maskLayer.path = path;
//        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
//
//        // Release the path since it's not covered by ARC.
//        overlayView.layer.mask = maskLayer
//        overlayView.clipsToBounds = true
//    }
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                bottom: NSLayoutYAxisAnchor? = nil,
                paddingBottom: CGFloat = 0,
                left: NSLayoutXAxisAnchor? = nil,
                paddingLeft: CGFloat = 0,
                right: NSLayoutXAxisAnchor? = nil,
                paddingRight: CGFloat = 0,
                width: CGFloat = 0,
                height: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func breathe() {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.autoreverse, .repeat, .allowUserInteraction],
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        },
                       completion: nil
        )
    }
    
    func stopBreathing() {
        UIView.animate(withDuration: 0.5 ) {
            self.transform = CGAffineTransform.identity
        }
    }
    
}

