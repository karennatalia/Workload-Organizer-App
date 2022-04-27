//
//  CustomTagUILabel.swift
//  Workload Organizer App
//
//  Created by Karen Natalia on 28/04/22.
//

import UIKit

@IBDesignable class CustomTagUILabel: UILabel {

    @IBInspectable var horizontal: CGFloat = 5.0
    @IBInspectable var vertical: CGFloat = 2.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + (2*horizontal),
                      height: size.height + (2*vertical))
    }

}
