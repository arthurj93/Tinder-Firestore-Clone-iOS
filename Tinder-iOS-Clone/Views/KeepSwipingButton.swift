//
//  KeepSwipingButton.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 11/07/21.
//

import UIKit

class KeepSwipingButton: UIButton {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let gradientLayer: CAGradientLayer = .init()
        let leftColor = #colorLiteral(red: 1, green: 0.01176470588, blue: 0.4470588235, alpha: 1)
        let rightColor = #colorLiteral(red: 1, green: 0.3921568627, blue: 0.3176470588, alpha: 1)
        gradientLayer.colors = [leftColor.cgColor, rightColor.cgColor]
        gradientLayer.startPoint = .init(x: 0, y: 0.5)
        gradientLayer.endPoint = .init(x: 1, y: 0.5)

        let cornerRadius = rect.height / 2
        let maskLayer: CAShapeLayer = .init()

        let maskPath: CGMutablePath = .init()
        maskPath.addPath(UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath)

        maskPath.addPath(UIBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), cornerRadius: cornerRadius).cgPath)

        maskLayer.path = maskPath
        maskLayer.fillRule = .evenOdd

        gradientLayer.mask = maskLayer

        layer.insertSublayer(gradientLayer, at: 0)
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        gradientLayer.frame = rect
    }

}
