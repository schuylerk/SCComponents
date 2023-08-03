//
//  SCUpdateTableModel.swift
//  SCIMChat
//
//  Created by schuyler on 2023/2/15.
//

import Foundation

struct SCUpdateTableModel {
    var isCompleted: Bool = false
    var animated: Bool = false
    var update: (() -> Void)?
    var completion: ((Bool) -> Void)?
    
    func complete(_ arg: Bool) {
        completion?(arg)
    }
    
    init(update: (() -> Void)?, completion: ((Bool) -> Void)?) {
        self.update = update
        self.completion = completion
    }
}
