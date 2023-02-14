//
//  SCToastDelegate.swift
//
//  Created by schuyler.
//

import Foundation

protocol SCToastDelegate {
    func toastWasHidden(_ toastView: SCToastView)
}

extension SCToastDelegate {
    func toastWasHidden(_ toastView: SCToastView) {}
}
