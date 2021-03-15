//
//  String+Extension.swift
//  FaceDetection
//
//  Created by Achem Samuel on 3/15/21.
//

import UIKit

extension String {
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
}
