//
//  SCLoadMoreControlDelegate.swift
//
//  Created by schuyler
//

import Foundation

protocol SCLoadMoreControlDelegate {
    
    func loadMoreControlStopAnimate(_ loadMoreControl: SCLoadMoreControl)
    
    func loadMoreControlStartAnimate(_ loadMoreControl: SCLoadMoreControl)
    
    func loadMoreControlShouldIgnore() -> Bool
    
}
