//
//  SCTableAdapter.swift
//  SCIMChat
//
//  Created by schuyler on 2023/2/9.
//

import Foundation
import UIKit

class SCTableAdapter: SCAdapter {
    
    var estimatedHeightEnabled: Bool = false
    var isMergeUpdateEnabled: Bool = false
    var isUpdating: Bool = false
    var tableView: UITableView!
    var reloadSource: DispatchSourceUserDataAdd!
    var lock: DispatchSemaphore!
    var updateModels: [SCUpdateTableModel] = []
    
    override init?(scrollView: UIScrollView) {
        super.init(scrollView: scrollView)
        guard let tableView = scrollView as? UITableView else { return nil }
        self.tableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
        let queue = DispatchQueue(label: "com.sc.tableadapter.reload.source")
        let source = DispatchSource.makeUserDataAddSource(queue: queue)
        reloadSource = source
        reloadSource.setEventHandler {
            self._reloadTable()
        }
        reloadSource.resume()
        lock = DispatchSemaphore(value: 1)
    }
    
    static func create(tableView: UITableView) -> SCTableAdapter {
        return SCTableAdapter(scrollView: tableView)!
    }
    
//    static func isMergeUpdateEnabledDefaultValue() -> (() -> Void) {
//
//    }
    
//    static func setIsMergeUpdateEnabledDefaultValue(_ block: (() -> Void)) {
//
//    }
    
    func _executeUpdateModel(_ updateModel: SCUpdateTableModel) {
        let _ = lock.wait(timeout: .distantFuture)
        isUpdating = true
        lock.signal()
        _updateTable(update: updateModel.update, animated: updateModel.animated) { [self] arg in
            updateModel.complete(arg)
            let _ = lock.wait(timeout: .distantFuture)
            if updateModels.count > 0 {
                let model = updateModels.first!
                updateModels.remove(at: 0)
                lock.signal()
                _executeUpdateModel(model)
            } else {
                isUpdating = false
                lock.signal()
            }
        }
    }
    
    func _addUpdateModel(_ updateModel: SCUpdateTableModel) {
        let _ = lock.wait(timeout: .distantFuture)
        if isUpdating {
            updateModels.append(updateModel)
            lock.signal()
        } else {
            lock.signal()
            _executeUpdateModel(updateModel)
        }
    }
    
    func _updateTable(update: (() -> Void)?, animated: Bool, completion: ((Bool) -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?(true)
        }
        CATransaction.setDisableActions(!animated)
        CATransaction.setAnimationDuration(0.2)
        tableView.beginUpdates()
        update?()
        tableView.endUpdates()
        //__unwind { 未写
        scrollViewDidScroll(tableView)
    }
    
    func _reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func _addUpdateBlockForMergeUpdate(_ update: (() -> Void)?, animated: Bool, completion: ((Bool) -> Void)?) {
        guard update != nil else { return }
        var updateModel = SCUpdateTableModel(update: update, completion: completion)
        updateModel.animated = animated
        _addUpdateModel(updateModel)
    }
    
    func _reloadSectionItemForMergeUpdate(_ sectionItem: SCSectionItem, animation: UITableView.RowAnimation, completion: ((Bool) -> Void)?) {
        var updateModel = SCUpdateTableModel(update: { [self] in
            guard let index = indexOfSectionItem(sectionItem) else { return }
            let indecSet = IndexSet(integer: index)
            tableView.reloadSections(indecSet, with: animation)
        }, completion: completion)
        updateModel.animated = animation != .none
        _addUpdateModel(updateModel)
    }
    
    func _reloadCellItemForMergeUpdate(_ cellItem: SCCellItem, animation: UITableView.RowAnimation, completion: ((Bool) -> Void)?) {
        var updateModel = SCUpdateTableModel(update: { [self] in
            guard let indexPath = indexPathOfCellItem(cellItem) else { return }
            tableView.reloadRows(at: [indexPath], with: animation)
        }, completion: completion)
        updateModel.animated = animation != .none
        _addUpdateModel(updateModel)
    }
    
    func reloadTable() {
        if isMergeUpdateEnabled {
            reloadSource.add(data: 1)
        } else {
            tableView.reloadData()
        }
    }
    
    func performBatchUpdates(_ update: (() -> Void)?, animated: Bool, completion: ((Bool) -> Void)?) {
        if isMergeUpdateEnabled {
            _addUpdateBlockForMergeUpdate(update, animated: animated, completion: completion)
        } else {
            _updateTable(update: update, animated: animated, completion: completion)
        }
    }
    
    func cellItem(for cell: UITableViewCell) -> SCCellItem? {
        guard let indexPath = tableView.indexPath(for: cell) else { return nil }
        guard let cellItem = cellItem(at: indexPath) else { return nil }
        return cellItem
    }
    
    func reload(sectionItem: SCSectionItem, with rowAnimation: UITableView.RowAnimation, completion: ((Bool) -> Void)?) {
        guard let index = sectionItems.firstIndex(of: sectionItem) else {
            completion?(false)
            return
        }
        performBatchUpdates({ [self] in
            guard index < tableView.numberOfSections else { return }
            let indexSet = IndexSet(integer: index)
            tableView.reloadSections(indexSet, with: rowAnimation)
        }, animated: rowAnimation != .none, completion: completion)
    }
    
    func reload(cellItem: SCCellItem, with rowAnimation: UITableView.RowAnimation, completion: ((Bool) -> Void)?) {
        guard let indexPath = indexPathOfCellItem(cellItem) else {
            completion?(false)
            return
        }
        guard let indexPaths = tableView.indexPathsForVisibleRows else {
            completion?(false)
            return
        }
        guard indexPaths.contains(indexPath) else {
            completion?(false)
            return
        }
        performBatchUpdates({ [self] in
            tableView.reloadRows(at: [indexPath], with: rowAnimation)
        }, animated: rowAnimation != .none, completion: completion)
    }
    
    func heightForHeaderFooterItem(_ headerItem: SCSectionHeaderFooterItem?, tableView: UITableView) -> Double {
        if let headerItem = headerItem {
            return headerItem.viewHeight
        }
        if tableView.style == .plain {
            return 0
        } else {
            return Double.leastNormalMagnitude
        }
    }
    
    func viewforHeaderFooterItem(_ item: SCSectionHeaderFooterItem?,  tableView: UITableView) -> UIView? {
        guard let item = item else { return nil }
        guard item.isCustomView else { return nil }
        register(headerFooter: item)
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: item.identifier) else {
            return nil
        }
        item.render?(view)
        return view
    }
    
    func errorCell() -> UITableViewCell {
        return UITableViewCell(style: .default, reuseIdentifier: "sc_error_cell")
    }
    
    func register(headerFooter item: SCSectionHeaderFooterItem) {
        guard !(containsHeaderFooter(identifier: item.identifier)) else { return }
        if let viewNibName = item.viewNibName {
            let nib = UINib(nibName: viewNibName, bundle: nil)
            tableView.register(nib, forHeaderFooterViewReuseIdentifier: item.identifier)
        } else {
            if let viewClass = item.viewClass {
                tableView.register(viewClass, forHeaderFooterViewReuseIdentifier: item.identifier)
            }
        }
        addHeaderFooter(identifier: item.identifier)
    }
    
    func register(cellItem: SCCellItem) {
        guard !(containsCell(identifier: cellItem.identifier)) else { return }
        if let cellNibName = cellItem.cellNibName {
            let nib = UINib(nibName: cellNibName, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: cellItem.identifier)
        } else {
            if let cellClass = cellItem.cellClass {
                tableView.register(cellClass, forCellReuseIdentifier: cellItem.identifier)
            }
        }
        addCell(identifier: cellItem.identifier)
    }
    
    func removeSectionItem(at index: Int, animation: UITableView.RowAnimation, completion: ((Bool) -> Void)?) {
        guard index >= 0, index < sectionCount else {
            completion?(false)
            return
        }
        performBatchUpdates({ [self] in
            removeSectionItem(at: index)
            let indexSet = IndexSet(integer: index)
            tableView.deleteSections(indexSet, with: animation)
        }, animated: isAnimated(animation), completion: completion)
    }
    
    func removeSectionItem(_ sectionIem: SCSectionItem, animation: UITableView.RowAnimation, completion: ((Bool) -> Void)?) {
        guard let index = indexOfSectionItem(sectionIem) else {
            completion?(false)
            return
        }
        removeSectionItem(at: index, animation: animation, completion: completion)
    }
    
    func insertSectionItems(_ sectionItems: [SCSectionItem], at index: Int, animation: UITableView.RowAnimation, completion: ((Bool) -> Void)?) {
        guard sectionItems.count > 0 else {
            completion?(false)
            return
        }
        guard index >= 0, index <= sectionCount else {
            completion?(false)
            return
        }
        performBatchUpdates({ [self] in
            insertSectionItems(sectionItems, at: index)
            let indexSet = IndexSet(integersIn: index..<index+sectionItems.count)
            tableView.insertSections(indexSet, with: animation)
        }, animated: isAnimated(animation), completion: completion)
    }
    
    func isAnimated(_ animation: UITableView.RowAnimation) -> Bool {
        return animation != .none
    }
    
}

// MARK: UITableViewDelegate
extension SCTableAdapter: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionItem = sectionItem(in: section) else { return 0 }
        let headerItem = sectionItem.headerItem
        return heightForHeaderFooterItem(headerItem, tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let sectionItem = sectionItem(in: section) else { return 0 }
        let footerItem = sectionItem.footerItem
        return heightForHeaderFooterItem(footerItem, tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionItem = sectionItem(in: section) else { return nil }
        let headerItem = sectionItem.headerItem
        return viewforHeaderFooterItem(headerItem, tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let sectionItem = sectionItem(in: section) else { return nil }
        let footerItem = sectionItem.footerItem
        return viewforHeaderFooterItem(footerItem, tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionItem = sectionItem(in: section) else { return nil }
        let headerItem = sectionItem.headerItem
        return headerItem?.title
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let sectionItem = sectionItem(in: section) else { return nil }
        let footerItem = sectionItem.footerItem
        return footerItem?.title
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cellItem = cellItem(at: indexPath) else { return }
        cellItem.isRendering = false
        if cellItem.cellHeight == UITableView.automaticDimension {
//            cell.frame.height
//            cellItem.estimatedCellHeight
        }
        let isValid = cellItem.isValidCellClass(cell)
        if let cellWillDisplayAction = cellItem.cellWillDisplayAction, isValid {
            cellWillDisplayAction()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let indexPath2 = tableView.indexPath(for: cell) else { return }
        guard indexPath == indexPath2 else { return }
        guard let cellItem = cellItem(at: indexPath) else { return }
        let isValid = cellItem.isValidCellClass(cell)
        if let cellDidEndDisplayingAction = cellItem.cellDidEndDisplayingAction, isValid {
            cellDidEndDisplayingAction()
        }
        if let detach = cellItem.detach, isValid {
            detach()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cellItem = cellItem(at: indexPath) else { return }
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cellItem.cellDidSelectAction?(cell)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellItem = cellItem(at: indexPath) else { return 0 }
        if cellItem.cellHeight == UITableView.automaticDimension {
            return cellItem.estimatedCellHeight
        } else {
            return max(cellItem.cellHeight, 0)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellItem = cellItem(at: indexPath) else { return 0 }
//        print("正在返回 section: \(indexPath.section) row: \(indexPath.row) 的高度")
        var cellHeight: Double
        if let cellHeightBlock = cellItem.cellHeightBlock {
            cellHeight = cellHeightBlock()
            cellItem.cellHeight = cellHeight
        } else {
            cellHeight = cellItem.cellHeight
        }
        if cellHeight == UITableView.automaticDimension {
            return cellHeight
        } else {
            return max(cellHeight, 0)
        }
    }
    
}

// MARK: UITableViewDataSource
extension SCTableAdapter: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        print("section总数：\(sectionCount)")
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("section:\(section) cell总数：\(cellCountInSection(section))")
        return cellCountInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionItem = sectionItem(in: indexPath.section) else {
            return errorCell()
        }
        sectionItem.reloadAction = { [self] rowAnimation, completion in
            reload(sectionItem: sectionItem, with: rowAnimation, completion: completion)
        }
        guard let cellItem = sectionItem.cellItem(at: indexPath.row) else {
            return errorCell()
        }
//        print("正在设置section:\(indexPath.section) row:\(indexPath.row)")
        register(cellItem: cellItem)
        cellItem.reloadAction = { [self] rowAnimation, completion in
            reload(cellItem: cellItem, with: rowAnimation, completion: { _ in
                completion?()
            })
        }
        if cellItem.disableCellAnimation && !(CATransaction.disableActions()) {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            let cell = tableView.dequeueReusableCell(withIdentifier: cellItem.identifier, for: indexPath)
            cellItem.isRendering = true
            cellItem.sectionItem = sectionItem
            cellItem.render?(cell)
            CATransaction.commit()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellItem.identifier, for: indexPath)
            cellItem.isRendering = true
            cellItem.sectionItem = sectionItem
            cellItem.render?(cell)
            return cell
        }
    }
    
}
