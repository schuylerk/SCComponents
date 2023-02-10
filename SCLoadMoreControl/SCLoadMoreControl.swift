//
//  SCLoadMoreControl.swift
//
//  Created by schuyler
//

import UIKit

class SCLoadMoreControl {
    
    var delegate: SCLoadMoreControlDelegate?
    
    var spacingFromLastCell: Double = 0
    
    var activityIndicatorView: UIActivityIndicatorView?
    
    var scrollView: UIScrollView?
    
    var oldInsetBottom: Double = 0
    
    init(with scrollView: UIScrollView, spacingFromLastCell: Double) {
        self.scrollView = scrollView
        self.spacingFromLastCell = spacingFromLastCell
        self.oldInsetBottom = scrollView.contentInset.bottom
        initView()
    }
    
    func initView() {
        guard let scrollView = scrollView else {
            return
        }
        let indicatorView = UIActivityIndicatorView()
        let x = (scrollView.frame.size.width - 40) / 2
        let y = scrollView.contentSize.height + spacingFromLastCell
        indicatorView.frame = CGRect(x: x, y: y, width: 40, height: 40)
        indicatorView.hidesWhenStopped = true
        indicatorView.autoresizingMask = .flexibleBottomMargin
        indicatorView.isHidden = true
        indicatorView.color = UIColor(red: 0, green: 0x78/255.0, blue: 0xB9/255.0, alpha: 1)
        scrollView.addSubview(indicatorView)
        activityIndicatorView = indicatorView
    }
    
    func endAnimating(_ notifyOrNot: Bool) {
        guard let activityIndicatorView = activityIndicatorView else {
            return
        }
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
        guard notifyOrNot else { return }
        delegate?.loadMoreControlStopAnimate(self)
    }
    
    func stop(_ notifyOrNot: Bool) {
        guard let scrollView = scrollView else {
            return
        }
        let isOnBottom = (scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.height)) >= 0
        if isOnBottom {
            endAnimating(notifyOrNot)
            UIView.animate(withDuration: 0.3, animations: { [self] in
                let contentInset = scrollView.contentInset
                scrollView.contentInset = UIEdgeInsets(top: contentInset.top, left: contentInset.left, bottom: oldInsetBottom, right: contentInset.right)
            })
        } else {
            let contentInset = scrollView.contentInset
            scrollView.contentInset = UIEdgeInsets(top: contentInset.top, left: contentInset.left, bottom: oldInsetBottom, right: contentInset.right)
            endAnimating(notifyOrNot)
        }
    }
    
    func didScroll() {
        guard let scrollView = scrollView else {
            return
        }
        guard let activityIndicatorView = activityIndicatorView else {
            return
        }
        guard shouldScroll() else { return }
        guard scrollView.contentOffset.y > 0 else { return }
        let origin = activityIndicatorView.frame.origin
        activityIndicatorView.frame.origin = CGPoint(x: origin.x, y: defaultY())
        guard !activityIndicatorView.isAnimating else { return }
        guard activityIndicatorView.isHidden else { return }
        
        activityIndicatorView.isHidden = false
        oldInsetBottom = scrollView.contentInset.bottom
        UIView.animate(withDuration: 0.3, animations: {
            let contentInset = scrollView.contentInset
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50 + contentInset.bottom, right: 0)
        }, completion: { [self] _ in
            activityIndicatorView.startAnimating()
            delegate?.loadMoreControlStartAnimate(self)
        })
    }
    
    func shouldScroll() -> Bool {
        guard let delegate = delegate else {
            return true
        }
        return !(delegate.loadMoreControlShouldIgnore())
    }
    
    func defaultY() -> Double {
        guard let scrollView = scrollView else {
            return 0.0
        }
        return scrollView.contentSize.height
    }
    
}
