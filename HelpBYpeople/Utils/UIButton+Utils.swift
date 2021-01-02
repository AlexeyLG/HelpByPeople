//
//  UIButton+Utils.swift
//  HelpBYpeople
//
//  Created by Alexey on 11/26/20.
//

import UIKit

extension UIButton {
    
    func roundCorners(corners: CACornerMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner], radius: CGFloat = 8) {
        layer.cornerRadius = radius
        layer.maskedCorners = corners
    }
}
