//
//  UIColor.swift
//  GameOfChats
//
//  Created by Andy Stef on 1/3/17.
//  Copyright © 2017 Andy Stef. All rights reserved.
//

import UIKit
import Foundation

extension UIColor {

    class func getColorWith(red: Int, green: Int, blue: Int, alpha: Float) -> UIColor {
        let resultColor = UIColor(colorLiteralRed: Float(red) / 255, green: Float(green) / 255, blue: Float(blue) / 255, alpha: alpha)

        return resultColor
    }

    class func getColorWith(red: Int, green: Int, blue: Int) -> UIColor {
        let resultColor = UIColor(colorLiteralRed: Float(red) / 255, green: Float(green) / 255, blue: Float(blue) / 255, alpha: 1.0)

        return resultColor
    }

    convenience init(r: Float, g: Float, b: Float) {
        self.init(colorLiteralRed: r / 255, green: g / 255, blue: b / 255, alpha: 1.0)
    }
}
