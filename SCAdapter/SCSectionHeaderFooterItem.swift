//
//  SCSectionHeaderFooterItem.swift
//  SCIMChat
//
//  Created by schuyler on 2023/2/14.
//

import Foundation
import UIKit

class SCSectionHeaderFooterItem {
    var identifier: String = ""
    var viewNibName: String?
    var viewClass: AnyClass?
    var title: String?
    var viewHeight: Double = 0.0
    var viewWidth: Double = 0.0
    var kind: String = ""
    var render: ((UITableViewHeaderFooterView) -> Void)?
    
    var viewSize: CGSize {
        return .zero
    }
    
    var isCustomView: Bool {
        guard viewNibName == nil else { return true }
        guard viewClass == nil else { return true }
        return false
    }
    
    static func create(identifier: String, viewClass: AnyClass) -> SCSectionHeaderFooterItem {
        return SCSectionHeaderFooterItem(identifier: identifier, viewNibName: nil, viewClass: viewClass, title: nil)
    }
    
    static func create(identifier: String, viewNibName: String) -> SCSectionHeaderFooterItem {
        return SCSectionHeaderFooterItem(identifier: identifier, viewNibName: viewNibName, viewClass: nil, title: nil)
    }
    
    static func create(identifier: String, title: String) -> SCSectionHeaderFooterItem {
        return SCSectionHeaderFooterItem(identifier: identifier, viewNibName: nil, viewClass: nil, title: title)
    }
    
    init(identifier: String, viewNibName: String?, viewClass: AnyClass?, title: String?) {
        self.identifier = identifier
        self.viewNibName = viewNibName
        self.viewClass = viewClass
        self.title = title
    }
}
