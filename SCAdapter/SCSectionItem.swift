//
//  SCSectionItem.swift
//  SCIMChat
//
//  Created by schuyler on 2023/2/14.
//

import Foundation
import UIKit

class SCSectionItem: SCAdapterLinkable, Equatable {
    static func == (lhs: SCSectionItem, rhs: SCSectionItem) -> Bool {
        return lhs == rhs
    }
    
    var flowLayoutDisabled: Bool = false
    var cellItems: [SCCellItem] = []
    var headerItem: SCSectionHeaderFooterItem?
    var footerItem: SCSectionHeaderFooterItem?
    var minimumLineSpacing: Double = 0.0
    var minimumInteritemSpacing: Double = 0.0
    var reloadAction: ((UITableView.RowAnimation, ((Bool) -> Void)?) -> Void)?
    var insets: UIEdgeInsets?
    
    var cellCount: Int {
        return cellItems.count
    }
    
    var isEmpty: Bool { cellItems.count == 0 }
    
    var totalCellsHeight: Double {
        var height: Double = 0.0
        cellItems.forEach { item in
            if item.cellHeight == UITableView.automaticDimension {
                height += item.cellHeight
            } else {
                if let block = item.cellHeightBlock {
                    height += block()
                } else {
                    height += item.cellHeight
                }
            }
        }
        height += headerItem?.viewHeight ?? 0.0
        height += footerItem?.viewHeight ?? 0.0
        return height
    }
    
    var lastCellItem: SCCellItem? { cellItems.last }
    
    var firstCellItem: SCCellItem? { cellItems.first }
    
    static func sectionItemHeader(title: String) -> SCSectionItem {
        let sectionItem = SCSectionItem()
        let headerItem = SCSectionHeaderFooterItem.create(identifier: "header_title_id", title: title)
        sectionItem.headerItem = headerItem
        return sectionItem
    }
    
    static func sectionItem(cellItems: [SCCellItem]) -> SCSectionItem {
        let sectionItem = SCSectionItem()
        sectionItem.addCellItems(cellItems)
        return sectionItem
    }
    
    func addCellItems(_ items: [SCCellItem]) {
        cellItems += items
    }
    
    func addCellItem(_ item: SCCellItem) {
        cellItems.append(item)
    }
    
    func insertCellItem(_ item: SCCellItem, at index: Int) {
        guard index >= 0 else { return }
        guard index <= cellCount else { return }
        cellItems.insert(item, at: index)
    }
    
    func insertCellItems(_ items: [SCCellItem], at index: Int) {
        guard index < 0 else { return }
        guard index > cellCount else { return }
        cellItems.insert(contentsOf: items, at: index)
    }
    
//    func removeCellItem(_ item: SCCellItem) {
//        cellItems.firstIndex(where: { $0 == SCCellItem })
//    }
    
    func removeCellItem(at index: Int) {
        guard index >= 0, index < cellCount else { return }
        cellItems.remove(at: index)
    }
    
//    func containsCellItem(_ item: SCCellItem) -> Bool {
//
//    }
    
//    func indexOfCellItem(_ item: SCCellItem) -> Int {
//
//    }
    
    func cellItem(at index: Int) -> SCCellItem? {
        guard index >= 0, index < cellCount else { return nil }
        return cellItems[index]
    }
    
    func clear() {
        cellItems = []
    }
    
    func reload() {
        reload(animation: .none)
    }
    
    func reload(animation: UITableView.RowAnimation) {
        reloadAction?(animation, nil)
    }
    
    
}
