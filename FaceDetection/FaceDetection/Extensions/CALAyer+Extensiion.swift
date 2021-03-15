//
//  CALAyer+Extensiion.swift
//  FaceDetection
//
//  Created by Achem Samuel on 3/15/21.
//

import UIKit

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
    
    func addTextLayer(frame: CGRect, color: CGColor, fontSize: CGFloat, font: UIFont? = UIFont.systemFont(ofSize: 13), text: String, alignment: CATextLayerAlignmentMode? = .center, animated: Bool, oldFrame: CGRect?, backgroundColor: CGColor? = UIColor.clear.cgColor) {
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.foregroundColor = color
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = alignment ?? .center
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = font ?? UIFont.systemFont(ofSize: 13)  //CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        textLayer.fontSize = fontSize
        textLayer.string = text
        textLayer.opacity = 1
        self.addSublayer(textLayer)
        
        if animated, let oldFrame = oldFrame {
            // "frame" property is not animatable in CALayer, so, I use "position" instead
            // Position is at the center of the frame (if you don't change the anchor point)
            let oldPosition = CGPoint(x: oldFrame.midX, y: oldFrame.midY)
            textLayer.animate(fromValue: oldPosition, toValue: textLayer.position, keyPath: "position")
        }
    }
}
