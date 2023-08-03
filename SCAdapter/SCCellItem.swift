//
//  SCCellItem.swift
//  SCIMChat
//
//  Created by schuyler on 2023/2/14.
//

import Foundation
import UIKit

class SCCellItem: SCAdapterLinkable {
    var selectable: Bool = true
    var disableCellAnimation: Bool = true
    var isRendering: Bool = true
    var identifier: String = ""
    var cellNibName: String?
    var cellClass: AnyClass?
    var cellWidth: Double = 0.0
    var cellHeight: Double = 0.0
    var cellHeightBlock: (() -> Double)?
    var cellWidthBlock: (() -> Void)?
    var dataModel: Any?
    var sectionItem: SCSectionItem?
    var render: ((UITableViewCell) -> Void)?
    var cellDidSelectAction: ((UITableViewCell) -> Void)?
    var cellWillDisplayAction: (() -> Void)?
    var cellDidEndDisplayingAction: (() -> Void)?
    var cellDidHighlightAction: (() -> Void)?
    var cellDidUnhighlightAction: (() -> Void)?
    var estimatedCellHeight: Double = 0.0
    var reloadAction: ((UITableView.RowAnimation, (() -> Void)?) -> Void)?
    var detach: (() -> Void)?
    
    init() {}
    
    init(identifier: String, cellNibName: String?, cellClass: AnyClass?, dataModel: Any?) {
        self.identifier = identifier
        self.cellNibName = cellNibName
        self.cellClass = cellClass
        self.dataModel = dataModel
    }
    
    static func createCell(identifier: String, style: UITableViewCell.CellStyle, dataModel: Any? = nil) -> SCCellItem {
        let cellClass: AnyClass = systemCellClass(style: style)
        return SCCellItem(identifier: identifier, cellNibName: nil, cellClass: cellClass, dataModel: dataModel)
    }
    
    static func createCell(identifier: String, nibName: String, dataModel: Any? = nil) -> SCCellItem {
        return SCCellItem(identifier: identifier, cellNibName: nibName, cellClass: nil, dataModel: nil)
    }
    
    static func createCell(identifier: String, cellClass: AnyClass, dataModel: Any? = nil) -> SCCellItem {
        return SCCellItem(identifier: identifier, cellNibName: nil, cellClass: cellClass, dataModel: dataModel)
    }
    
    static func createCell(_ cellClass: AnyClass, dataModel: Any) -> SCCellItem {
        let identifier = "sc_" + NSStringFromClass(cellClass) + "_cell"
        return SCCellItem(identifier: identifier, cellNibName: nil, cellClass: cellClass, dataModel: dataModel)
    }
    
    static func createCell(style: UITableViewCell.CellStyle, dataModel: Any) -> SCCellItem {
        let identifier = "" //sc_" + NSStringFromClass(dataModel) + "_cell"
        let cellClass: AnyClass = systemCellClass(style: style)
        return SCCellItem(identifier: identifier, cellNibName: nil, cellClass: cellClass, dataModel: dataModel)
    }
    
    static func createCell(nibName: String, dataModel: Any) -> SCCellItem {
        let identifier = "sc_" + nibName + "_cell"
        return SCCellItem(identifier: identifier, cellNibName: nibName, cellClass: nil, dataModel: dataModel)
    }
    
    static func systemCellClass(style: UITableViewCell.CellStyle) -> AnyClass {
        return style == .default ? SCSystemDefaultCell.self : SCSystemValue1Cell.self
    }
    
    static func placeHolderCellItem(height: CGFloat) -> SCCellItem {
        let cell = SCCellItem.createCell(identifier: "sc_placeholder_cell", style: .default)
        cell.cellHeight = height
        return cell
    }
    
    func isValidCellClass(_ cell: UITableViewCell) -> Bool {
        guard cellClass != nil else { return true }
        return cell.isKind(of: cellClass!)
    }
    
    func reload() {
        reload(animation: .none)
    }
    
    func reload(animation: UITableView.RowAnimation, completion: (() -> Void)? = nil) {
        guard !isRendering else { return }
        reloadAction?(animation, completion)
    }
    
}
