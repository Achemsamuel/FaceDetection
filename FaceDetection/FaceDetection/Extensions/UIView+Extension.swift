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
    
}

extension CALayer {
    func addCircleLayer(origin: CGPoint, radius: CGFloat, color: CGColor, animated: Bool, oldOrigin: CGPoint?) {
        let layer = CALayer()
        layer.frame = CGRect(x: origin.x, y: origin.y, width: radius * 2, height: radius * 2)
        layer.backgroundColor = color
        layer.cornerRadius = radius
        self.addSublayer(layer)
        
        if animated, let oldOrigin = oldOrigin {
            let oldFrame = CGRect(x: oldOrigin.x, y: oldOrigin.y, width: radius * 2, height: radius * 2)
            
            // "frame" property is not animatable in CALayer, so, I use "position" instead
            layer.animate(fromValue: CGPoint(x: oldFrame.midX, y: oldFrame.midY),
                          toValue: CGPoint(x: layer.frame.midX, y: layer.frame.midY),
                          keyPath: "position")
        }
    }
    
    func animate(fromValue: Any, toValue: Any, keyPath: String, _ duration: CFTimeInterval = 0.5) {
        let anim = CABasicAnimation(keyPath: keyPath)
        anim.fromValue = fromValue
        anim.toValue = toValue
        anim.duration = duration
        anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.add(anim, forKey: keyPath)
    }
}
