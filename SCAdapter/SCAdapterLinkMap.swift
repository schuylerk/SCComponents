//
//  SCAdapterLinkMap.swift
//  SCIMChat
//
//  Created by schuyler on 2023/2/14.
//

import Foundation

class SCAdapterLinkMap {
    
    var objectsMap: NSMapTable<AnyObject, AnyObject>
    
    init() {
        objectsMap = NSMapTable.strongToWeakObjects()
    }
    
    func linkedSectionItem(key: AnyObject) -> SCSectionItem? {
        let object = linkedObject(key: key)
        guard let sectionItem = object as? SCSectionItem else {
            return nil
        }
        return sectionItem
    }

    func linkedCellItem(key: AnyObject) -> SCCellItem? {
        let object = linkedObject(key: key)
        guard let cellItem = object as? SCCellItem else {
            return nil
        }
        return cellItem
    }
    
    func linkedObject(key: AnyObject) -> AnyObject? {
        return objectsMap.object(forKey: key)
    }
    
    func link(key: AnyObject, with object: AnyObject) {
        objectsMap.setObject(object, forKey: key)
    }
    
}
