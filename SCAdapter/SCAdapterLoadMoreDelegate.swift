//
//  SCAdapterLoadMoreDelegate.swift
//  SCIMChat
//
//  Created by schuyler on 2023/2/14.
//

import Foundation

@objc protocol SCAdapterLoadMoreDelegate {
    func adapterOnLoadMore(_ adapter: SCAdapter)
    func adapterLoadMoreOffset(_ adapter: SCAdapter) -> Double
    @objc optional func triggerLoadMoreIfNeeded(_ adapter: SCAdapter)
}

//extension SCAdapterLoadMoreDelegate {
//    func triggerLoadMoreIfNeeded(_ adapter: SCAdapter) {}
//}
