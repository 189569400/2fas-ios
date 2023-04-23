//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
//  Contributed by Zbigniew Cisiński. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <https://www.gnu.org/licenses/>
//

import UIKit
import Common

final class LabelRenderer: UIView {
    private var currentSize: TokensLogoSize = .normal
    
    private var circleWidthConstraint: NSLayoutConstraint?
    private var circleHeightConstraint: NSLayoutConstraint?
    
    private let circle = Circle()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Theme.Colors.Text.light
        label.font = Theme.Fonts.iconLabel
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()
    
    private var accessibilityColor: String?
    private var accessibilityText: String?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(
            origin: .zero,
            size: CGSize(width: currentSize.dimension, height: currentSize.dimension)
        ))
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(circle)
        circle.pinToParent()
        let width = circle.widthAnchor.constraint(equalToConstant: currentSize.dimension)
        let height = circle.heightAnchor.constraint(equalToConstant: currentSize.dimension)
        circleWidthConstraint = width
        circleHeightConstraint = height
        NSLayoutConstraint.activate([width, height])
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let margin = Theme.Metrics.standardMargin
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin)
        ])
        circle.setDimension(currentSize.dimension)
        
        isAccessibilityElement = true
    }
    
    func setColor(_ color: TintColor, animated: Bool) {
        circle.setColor(color.color, animated: animated)
        
        accessibilityColor = color.localizedName
        updateAccessibility()
    }
    
    func setText(_ text: String) {
        var newText = text.uppercased()
        if newText.count > 2 {
            newText = newText[0...2]
        }
        titleLabel.text = newText
        
        accessibilityText = text
        updateAccessibility()
    }
    
    func setSize(_ size: TokensLogoSize) {
        guard size != currentSize else { return }
        currentSize = size
        let dimension = currentSize.dimension
        switch size {
        case .small:
            titleLabel.font = Theme.Fonts.iconLabelSmall
        case .normal:
            titleLabel.font = Theme.Fonts.iconLabel
        }
        circleWidthConstraint?.constant = dimension
        circleHeightConstraint?.constant = dimension
        circle.setDimension(dimension)
        
        invalidateIntrinsicContentSize()
    }
    
    private func updateAccessibility() {
        guard let text = accessibilityText, let color = accessibilityColor else { return }
        accessibilityLabel = T.Voiceover.serviceLabelWithNameAndColor(text, color)
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: currentSize.dimension, height: currentSize.dimension)
    }
}

private final class Circle: UIView {
    private let animKey = "fillColor"
    private var dimension: CGFloat = TokensLogoSize.normal.dimension
    private var color: UIColor = .white
    
    override class var layerClass: AnyClass { CAShapeLayer.self }
    private var shapeLayer: CAShapeLayer { self.layer as! CAShapeLayer }
    
    override func layoutSubviews() {
        let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: dimension, height: dimension)))
        shapeLayer.path = path.cgPath
        
        super.layoutSubviews()
    }
    
    func setDimension(_ dimension: CGFloat) {
        self.dimension = dimension
        layoutIfNeeded()
    }
    
    func setColor(_ color: UIColor, animated: Bool) {
        self.color = color
        
        if animated {
            let animation = CABasicAnimation(keyPath: animKey)
            animation.duration = Theme.Animations.Timing.quick
            let fromValue: CGColor
            if
                let currentAnimation = shapeLayer.animation(forKey: animKey) as? CABasicAnimation,
                let value = currentAnimation.toValue {
                fromValue = value as! CGColor
                shapeLayer.removeAnimation(forKey: animKey)
            } else if let currentColor = shapeLayer.fillColor {
                fromValue = currentColor
            } else {
                fromValue = Theme.Colors.Fill.background.cgColor
            }
            animation.fromValue = fromValue
            animation.toValue = color.cgColor
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            shapeLayer.add(animation, forKey: animKey)
        } else {
            shapeLayer.fillColor = color.cgColor
        }
    }
}
