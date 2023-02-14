//
//  SCToastViewStyle.swift
//  SCIMChat
//
//  Created by schuyler on 2023/2/10.
//

import Foundation
import UIKit

class SCToastViewStyle {
    
    var bgColor: UIColor = .clear
    
    var contentColor: UIColor = .clear
    
    var toastIcon: String = ""
    
    static func defaultToastStyle() -> SCToastViewStyle {
        let style = SCToastViewStyle()
        style.bgColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        style.contentColor = .white
        return style
    }
    
}
