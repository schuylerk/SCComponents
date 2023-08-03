//
//  SCAdapter.swift
//  SCIMChat
//
//  Created by schuyler on 2023/2/9.
//

import Foundation
import UIKit

class SCAdapter: NSObject {
    var sectionItems: [SCSectionItem] = []
    var isLoading: Bool = false
    var scrollView: UIScrollView?
    var scrollViewDelegate: UIScrollViewDelegate?
    var loadMoreDelegate: SCAdapterLoadMoreDelegate?
    var linkMap: SCAdapterLinkMap?
    var cellIdentifiers: Set<String> = .init()
    var headerFooterIdentifiers: Set<String> = .init()
    
    var sectionCount: Int { sectionItems.count }
    
    init?(scrollView: UIScrollView) {
        let isTableView = scrollView.isKind(of: UITableView.self)
        let isCollectionView = scrollView.isKind(of: UICollectionView.self)
        if !isTableView && !isCollectionView {
            return nil
        }
        super.init()
        scrollView.delegate = self
        self.scrollView = scrollView
    }
    
    func triggerLoadMoreIfNeeded() {
        guard let delegate = loadMoreDelegate else { return }
        guard !isLoading else { return }
        if let _ = delegate.triggerLoadMoreIfNeeded {
            delegate.triggerLoadMoreIfNeeded?(self)
        } else {
            let loadMoreOffset = delegate.adapterLoadMoreOffset(self)
            guard let contentOffsetY = scrollView?.contentOffset.y else { return }
            guard let contentHeight = scrollView?.contentSize.height else { return }
            guard let frameHeight = scrollView?.frame.height else { return }
            contentHeight - frameHeight - loadMoreOffset
            isLoading = true
            delegate.adapterOnLoadMore(self)
        }
    }
    
    func performBatchUpdates(_ block: (() -> Void), animated: Bool, completion: (() -> Void)) {
        return
    }
    
    func subSectionItems(fromIndex: Int, toIndex: Int) -> [SCSectionItem]? {
        guard fromIndex >= 0 else { return nil }
        guard toIndex < sectionCount else { return nil }
        var items: [SCSectionItem] = []
        for index in fromIndex...toIndex {
            items.append(sectionItems[index])
        }
        return items
    }
    
    func subSectionItems(toIndex: Int) -> [SCSectionItem]? {
        return subSectionItems(fromIndex: 0, toIndex: toIndex)
    }
    
    func subSectionItems(fromIndex: Int) -> [SCSectionItem]? {
        return subSectionItems(fromIndex: fromIndex, toIndex: sectionCount - 1)
    }
    
    func cellItem(forCell: AnyClass) -> SCCellItem? {
        return nil
    }
    
//    func containsSectionItem(_ sectionItem: SCSectionItem) -> Bool {
//        return sectionItems.contains(where: { $0 == sectionItem })
//    }
    
    func removeSectionItem(at index: Int) {
        guard index >= 0, index < sectionCount else { return }
        sectionItems.remove(at: index)
    }
    
    func removeSectionItems(_ items: [SCSectionItem]) {
        
    }
    
    func removeSectionItem(_ item: SCSectionItem) {
        
    }
    
    func insertSectionItems(_ items: [SCSectionItem], at index: Int) {
        guard index >= 0, index <= sectionCount else { return }
        sectionItems.insert(contentsOf: items, at: index)
    }
    
    func insertSectionItem(_ item: SCSectionItem, at index: Int) {
        guard index >= 0, index <= sectionCount else { return }
        sectionItems.insert(item, at: index)
    }
    
    func addSectionItems(_ items: [SCSectionItem]) {
        sectionItems += items
    }
    
    func addSectionItem(_ item: SCSectionItem) {
        sectionItems.append(item)
    }
    
    func clear() {
        sectionItems.removeAll()
    }
    
    func cellItem(at indexPath: IndexPath) -> SCCellItem? {
        guard let sectioItem = sectionItem(in: indexPath.section) else { return nil }
        guard let cellItem = sectioItem.cellItem(at: indexPath.row) else { return nil }
        return cellItem
    }
    
    func indexPathOfCellItem(_ item: SCCellItem) -> IndexPath? {
        return nil
    }
    
    func sectionItem(in section: Int) -> SCSectionItem? {
        guard section >= 0, section < sectionCount else { return nil }
        return sectionItems[section]
    }
    
    func indexOfSectionItem(_ sectionItem: SCSectionItem) -> Int? {
        return nil
    }
    
    func cellCountInSection(_ section: Int) -> Int {
        let sectionItem = sectionItem(in: section)
        return sectionItem?.cellCount ?? 0
    }
    
    func containsHeaderFooter(identifier: String) -> Bool {
        return headerFooterIdentifiers.contains(where: { $0 == identifier })
    }
    
    func containsCell(identifier: String) -> Bool {
        return cellIdentifiers.contains(where: { $0 == identifier })
    }
    
    func addHeaderFooter(identifier: String) {
        headerFooterIdentifiers.insert(identifier)
    }
    
    func addCell(identifier: String) {
        cellIdentifiers.insert(identifier)
    }
    
    func scim_reload() {
        if let tableView = scrollView as? UITableView {
            tableView.reloadData()
        } else if let collectionView = scrollView as? UICollectionView {
            collectionView.reloadData()
        }
    }
    
    func scim_reloadComplete(_ completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
    }
    
}

extension SCAdapter: UIScrollViewDelegate {
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidScrollToTop?(scrollView)
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        guard let scrollViewDelegate = scrollViewDelegate else {
            return false
        }
        guard let scrollViewShouldScrollToTop = scrollViewDelegate.scrollViewShouldScrollToTop else {
            return false
        }
        return scrollViewShouldScrollToTop(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollViewDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }
    
}
 
