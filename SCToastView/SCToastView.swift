//
//  SCToastView.swift
//
//  Created by schuyler
//

import UIKit

class SCToastView: UIView {
    
    var delegate: SCToastDelegate?
    
    var centerYOffset: Double = 0
    
    var centerXOffset: Double = 0
    
    var toastType: ToastType = .plain
    
    var contentColor: UIColor = .clear
    
    var contentText: String = ""
    
    var contentAttributeText: NSAttributedString = NSAttributedString()
    
    var cornerRadius: Double = 8
    
    var customView: UIView?
    
    var textLabelFontForTypeTextOnly: UIFont? = UIFont(name: "Arial", size: 15)
    
    var textLabelFontForOtherType: UIFont? = UIFont(name: "Arial", size: 20)
    
    var statesImageView: UIImageView?
    
    var carrierView: UIView?
    
    var showSeconds: Double = 0
    
    var hideTimer: Timer?
    
    var margin: Double = 15
    
    var textMargin: Double = 10
    
    var paragraphStyle: NSParagraphStyle = .default
    
    var style: SCToastViewStyle = .defaultToastStyle()
    
    var edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    
    lazy var roundRectView: UIView = {
        let roundRView = UIView()
        roundRView.backgroundColor = style.bgColor
        roundRView.layer.cornerRadius = cornerRadius
        return roundRView
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = contentColor
        label.font = textLabelFontForTypeTextOnly
        label.isOpaque = false
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()

    // MARK: 初始化
    init(frame: CGRect, with carrierView: UIView, message: String, toastType: ToastType, showDuration: Double) {
        super.init(frame: frame)
        commonInit()
        self.carrierView = carrierView
        self.toastType = toastType
        self.contentText = message
        self.showSeconds = showDuration
        textLabel.text = message
    }
    
    
    init(frame: CGRect, with carrierView: UIView, attributeMessage: NSAttributedString, toastType: ToastType, showDuration: Double) {
        super.init(frame: frame)
        commonInit()
        self.carrierView = carrierView
        self.toastType = toastType
        self.contentAttributeText = attributeMessage
        self.showSeconds = showDuration
        textLabel.attributedText = attributeMessage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        contentColor = style.contentColor
        isOpaque = false
        setUpViews()
    }
    
    func setUpViews() {
        addSubview(roundRectView)
        addSubview(textLabel)
    }
    
    func updateViews() {
        if customView?.superview != nil {
            customView?.removeFromSuperview()
        }
        switch toastType {
        case .plain:
            resetTextOnlyToastView()
        case .failed, .custom, .success:
            resetViewWith(toastType: toastType)
        }
    }
    
    // MARK: CUSTOM
    static func showToastWith(customView: UIView, attributeMessage: NSAttributedString, inView: UIView, duration: Double) -> SCToastView {
        let toastView = SCToastView(frame: .zero, with: inView, attributeMessage: attributeMessage, toastType: .custom, showDuration: duration)
        toastView.customView = customView
        toastView.showToastWith(duration: duration)
        return toastView
    }
    
    static func showToastWith(customView: UIView, attributeMessage: NSAttributedString, inView: UIView) -> SCToastView {
        return showToastWith(customView: customView, attributeMessage: attributeMessage, inView: inView, duration: 2.0)
    }
    
    static func showToastWith(customView: UIView, message: String, inView: UIView, duration: Double) -> SCToastView {
        let toastView = SCToastView(frame: .zero, with: inView, message: message, toastType: .custom, showDuration: duration)
        toastView.customView = customView
        toastView.showToastWith(duration: duration)
        return toastView
    }
    
    static func showToastWith(customView: UIView, message: String, inView: UIView) -> SCToastView {
        return showToastWith(customView: customView, message: message, inView: inView, duration: 2.0)
    }
    
    // MARK: PLAIN
    static func showAttributeMessageToast(_ message: NSAttributedString, inView: UIView, duration: Double) -> SCToastView {
        let toastView = SCToastView(frame: .zero, with: inView, attributeMessage: message, toastType: .plain, showDuration: duration)
        toastView.showToastWith(duration: duration)
        return toastView
    }
    
    static func showAttributeMessageToast(_ message: NSAttributedString, inView: UIView) -> SCToastView {
        return showAttributeMessageToast(message, inView: inView, duration: 2.0)
    }
    
    static func showToast(_ message: String, inView: UIView, duration: Double) -> SCToastView {
        let toastView = SCToastView(frame: .zero, with: inView, message: message, toastType: .plain, showDuration: duration)
        toastView.showToastWith(duration: duration)
        return toastView
    }
    
    static func showToast(_ message: String, inView: UIView) -> SCToastView {
        return showToast(message, inView: inView, duration: 2.0)
    }
    
    // MARK: FAILED
    static func showFailedToast(_ message: String, inView: UIView, duration: Double) {
        let toastView = SCToastView(frame: .zero, with: inView, message: message, toastType: .failed, showDuration: duration)
        toastView.showToastWith(duration: duration)
    }
    
    static func showFailedToast(_ message: String, inView: UIView) {
        showFailedToast(message, inView: inView, duration: 2.0)
    }
    
    // MARK: SUCCESS
    static func showSuccessToast(_ message: String, inView: UIView, duration: Double) {
        let toastView = SCToastView(frame: .zero, with: inView, message: message, toastType: .success, showDuration: duration)
        toastView.showToastWith(duration: duration)
    }
    
    static func showSuccessToast(_ message: String, inView: UIView) {
        showSuccessToast(message, inView: inView, duration: 2.0)
    }
    
    // MARK: RESET
    func resetTextOnlyToastView() {
        guard let carrierView = carrierView else { return }
        textLabel.font = textLabelFontForTypeTextOnly
        resetImageView()
        let size = computeContentSize()
        roundRectView.frame = CGRect(x: 0, y: 0, width: size.width + margin * 2, height: size.height + textMargin * 2)
        textLabel.frame = CGRect(x: margin, y: textMargin, width: size.width, height: size.height)
        let x = (carrierView.frame.width - roundRectView.frame.width) / 2 + centerXOffset
        let y = (carrierView.frame.height - roundRectView.frame.height) / 2 + centerYOffset
        let width = roundRectView.frame.width
        let height = roundRectView.frame.height
        self.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    func resetViewWith(toastType: ToastType) {
        var imageView: UIImageView
        guard toastType != .plain else { return }
        guard toastType != .custom else {
            textLabel.font = textLabelFontForOtherType
            resetImageView()
            addSubview(customView!)
            updateCustomViewLayout()
            return
        }
        textLabel.font = textLabelFontForOtherType
        resetImageView()
        imageView = UIImageView(image: UIImage(named: toastType == .success ? "icon_success" : "icon_failed"))
        addSubview(imageView)
        statesImageView = imageView
        updateStatesStyleViews()
    }
    
    func resetImageView() {
        if let statesImageView = statesImageView {
            statesImageView.removeFromSuperview()
            self.statesImageView = nil
        }
        if let customView = customView {
            customView.removeFromSuperview()
        }
    }
    
    // MARK: COMPUTE
    func computeCustomContentSize() -> CGSize {
        var size: CGSize
        if contentAttributeText.length > 0 {
            size = contentAttributeText.boundingRect(with: CGSize(width: 250.0, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).size
        } else {
            size = NSString(string: contentText).boundingRect(with: CGSize(width: 262.0, height: CGFloat.greatestFiniteMagnitude), options: .truncatesLastVisibleLine, attributes: [.font: textLabel.font as Any, .paragraphStyle: paragraphStyle], context: nil).size
        }
        return size
    }
    
    func computeContentSize() -> CGSize {
        var size: CGSize
        if contentAttributeText.length > 0 {
            size = contentAttributeText.boundingRect(with: CGSize(width: 250.0, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size
        } else {
            size = NSString(string: contentText).boundingRect(with: CGSize(width: 250.0, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: textLabel.font as Any], context: nil).size
        }
        return size
    }
    
    // MARK: UPDATE
    func updateCustomViewLayout() {
        guard let customView = customView else { return }
        guard let carrierView = carrierView else { return }
        let size = computeCustomContentSize()
        let min = min(customView.frame.width, 262.0)
        let width = customView.frame.width > size.width ? min : size.width
        let height = edgeInsets.top + customView.frame.height + edgeInsets.bottom + size.height + 17
        roundRectView.frame = CGRect(x: 0, y: 0, width: width + 28, height: height)
        let x = (roundRectView.frame.width - customView.frame.width) / 2
        customView.frame = CGRect(x: x, y: edgeInsets.top, width: customView.frame.width, height: customView.frame.height)
        let xx = (roundRectView.frame.width - size.width) / 2
        let yy = customView.frame.maxY + edgeInsets.bottom
        textLabel.frame = CGRect(x: xx, y: yy, width: size.width, height: size.height)
        let xxx = (carrierView.frame.width - roundRectView.frame.width) / 2 + centerXOffset
        let yyy = (carrierView.frame.height - roundRectView.frame.height) / 2 + centerYOffset
        let widthw = roundRectView.frame.width
        let heighth = roundRectView.frame.height
        self.frame = CGRect(x: xxx, y: yyy, width: widthw, height: heighth)
    }
    
    func updateStatesStyleViews() {
        let x = (carrierView!.frame.width - 115.0) * 0.5 + centerXOffset
        let y = (carrierView!.frame.height - 115.0) * 0.5 + centerYOffset
        self.frame = CGRect(x: x, y: y, width: 115.0, height: 115.0)
        roundRectView.frame = CGRect(x: 0, y: 0, width: 115.0, height: 115.0)
        statesImageView!.frame = CGRect(x: 37.5, y: 22.0, width: 40, height: 40)
        textLabel.frame = CGRect(x: 0, y: statesImageView!.frame.maxY + 10.0, width: 115.0, height: 17.0)
    }
    
    func animateIn(_ animateIn: Bool, completion: ((Bool) -> Void)?) {
        let scale1 = CGAffineTransform(scaleX: 0.8, y: 0.8)
        let scale2 = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.transform = animateIn ? scale1 : scale2
        UIView.animate(withDuration: 0.43, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.transform = animateIn ? scale2 : scale1
            self.alpha = animateIn ? 1 : 0
        }, completion: completion)
    }
    
    // MARK: 消失
    func hide(_ animated: Bool) {
        animated ? hideAnimated() : hideImmediately()
    }
    
    func hideImmediately() {
        if hideTimer != nil {
            hideTimer!.invalidate()
            hideTimer = nil
        }
        self.removeFromSuperview()
        delegate?.toastWasHidden(self)
    }
    
    @objc func hideAnimated() {
        if hideTimer != nil {
            hideTimer!.invalidate()
            hideTimer = nil
        }
        animateIn(false, completion: { _ in
            self.removeFromSuperview()
            self.delegate?.toastWasHidden(self)
        })
    }
    
    // MARK: 显示
    func showToastWith(duration: Double, associatedToastView: UInt8) {
        updateViews()
        guard let carrierView = carrierView else { return }
        carrierView.addSubview(self)
        animateIn(true, completion: nil)
        if duration > 0 {
            let timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(hideAnimated), userInfo: nil, repeats: false)
            RunLoop.current.add(timer, forMode: .common)
            hideTimer = timer
        }
    }
    
    func showToastWith(duration: Double) {
        showToastWith(duration: duration, associatedToastView: 0)
    }
    
    func show() {
        showToastWith(duration: 0)
    }
    
}

extension SCToastView {
    enum ToastType {
        case plain
        case custom
        case success
        case failed
    }
}

