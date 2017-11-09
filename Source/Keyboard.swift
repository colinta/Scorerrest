////
///  Keyboard.swift
//

import UIKit
import Foundation
import CoreGraphics

open class Keyboard {
    struct Notifications {
        static let KeyboardWillShow = TypedNotification<Keyboard>(name: "co.colinta.Keyboard.KeyboardWillShow")
        static let KeyboardDidShow = TypedNotification<Keyboard>(name: "co.colinta.Keyboard.KeyboardDidShow")
        static let KeyboardWillHide = TypedNotification<Keyboard>(name: "co.colinta.Keyboard.KeyboardWillHide")
        static let KeyboardDidHide = TypedNotification<Keyboard>(name: "co.colinta.Keyboard.KeyboardDidHide")
    }

    open static let shared = Keyboard()

    open class func setup() {
        let _ = shared
    }

    open var active = false
    open var external = false
    open var bottomInset: CGFloat = 0.0
    open var endFrame: CGRect = .zero
    open var curve = UIViewAnimationCurve.linear
    open var options = UIViewAnimationOptions.curveLinear
    open var duration: Double = 0.0

    init() {
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(Keyboard.willShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(Keyboard.didShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        center.addObserver(self, selector: #selector(Keyboard.willHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        center.addObserver(self, selector: #selector(Keyboard.didHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }

    deinit {
        let center: NotificationCenter = NotificationCenter.default
        center.removeObserver(self)
    }

    open func keyboardBottomInset(inView: UIView) -> CGFloat {
        let window: UIView = inView.window ?? inView
        let bottom = window.convert(CGPoint(x: 0, y: window.bounds.size.height - bottomInset), to: inView.superview).y
        let inset = inView.frame.size.height - bottom
        if inset < 0 {
            return 0
        }
        else {
            return inset
        }
    }

    @objc
    func didShow(_ notification: Notification) {
        postNotification(Notifications.KeyboardDidShow, value: self)
    }

    @objc
    func didHide(_ notification: Notification) {
        postNotification(Notifications.KeyboardDidHide, value: self)
    }

    func setFromNotification(_ notification: Notification) {
        if let durationValue = (notification as NSNotification).userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            duration = durationValue.doubleValue
        }
        else {
            duration = 0
        }
        if let rawCurveValue = ((notification as NSNotification).userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber) {
            let rawCurve = rawCurveValue.intValue
            curve = UIViewAnimationCurve(rawValue: rawCurve) ?? .easeOut
            let curveInt = UInt(rawCurve << 16)
            options = UIViewAnimationOptions(rawValue: curveInt)
        }
        else {
            curve = .easeOut
            options = .curveEaseOut
        }
    }

    @objc
    func willShow(_ notification: Notification) {
        active = true
        setFromNotification(notification)
        endFrame = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let window = UIWindow.mainWindow
        bottomInset = window.frame.size.height - endFrame.origin.y
        external = endFrame.size.height > bottomInset

        postNotification(Notifications.KeyboardWillShow, value: self)
    }

    @objc
    func willHide(_ notification: Notification) {
        setFromNotification(notification)
        endFrame = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        bottomInset = 0

        let windowBottom = UIWindow.mainWindow.frame.size.height
        if endFrame.origin.y >= windowBottom {
            active = false
            external = false
        }
        else {
            external = true
        }

        postNotification(Notifications.KeyboardWillHide, value: self)
    }
}
