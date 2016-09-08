////
///  Keyboard.swift
//

import UIKit
import Foundation
import CoreGraphics

public class Keyboard {
    public struct Notifications {
        public static let KeyboardWillShow = TypedNotification<Keyboard>(name: "co.colinta.Keyboard.KeyboardWillShow")
        public static let KeyboardDidShow = TypedNotification<Keyboard>(name: "co.colinta.Keyboard.KeyboardDidShow")
        public static let KeyboardWillHide = TypedNotification<Keyboard>(name: "co.colinta.Keyboard.KeyboardWillHide")
        public static let KeyboardDidHide = TypedNotification<Keyboard>(name: "co.colinta.Keyboard.KeyboardDidHide")
    }

    public static let shared = Keyboard()

    public class func setup() {
        let _ = shared
    }

    public var active = false
    public var external = false
    public var bottomInset: CGFloat = 0.0
    public var endFrame: CGRect = .zero
    public var curve = UIViewAnimationCurve.Linear
    public var options = UIViewAnimationOptions.CurveLinear
    public var duration: Double = 0.0

    public init() {
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: #selector(Keyboard.willShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(Keyboard.didShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        center.addObserver(self, selector: #selector(Keyboard.willHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(Keyboard.didHide(_:)), name: UIKeyboardDidHideNotification, object: nil)
    }

    deinit {
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.removeObserver(self)
    }

    public func keyboardBottomInset(inView inView: UIView) -> CGFloat {
        let window: UIView = inView.window ?? inView
        let bottom = window.convertPoint(CGPoint(x: 0, y: window.bounds.size.height - bottomInset), toView: inView.superview).y
        let inset = inView.frame.size.height - bottom
        if inset < 0 {
            return 0
        }
        else {
            return inset
        }
    }

    @objc
    func didShow(notification: NSNotification) {
        postNotification(Notifications.KeyboardDidShow, value: self)
    }

    @objc
    func didHide(notification: NSNotification) {
        postNotification(Notifications.KeyboardDidHide, value: self)
    }

    func setFromNotification(notification: NSNotification) {
        if let durationValue = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            duration = durationValue.doubleValue
        }
        else {
            duration = 0
        }
        if let rawCurveValue = (notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber) {
            let rawCurve = rawCurveValue.integerValue
            curve = UIViewAnimationCurve(rawValue: rawCurve) ?? .EaseOut
            let curveInt = UInt(rawCurve << 16)
            options = UIViewAnimationOptions(rawValue: curveInt)
        }
        else {
            curve = .EaseOut
            options = .CurveEaseOut
        }
    }

    @objc
    func willShow(notification: NSNotification) {
        active = true
        setFromNotification(notification)
        endFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let window = UIWindow.mainWindow
        bottomInset = window.frame.size.height - endFrame.origin.y
        external = endFrame.size.height > bottomInset

        postNotification(Notifications.KeyboardWillShow, value: self)
    }

    @objc
    func willHide(notification: NSNotification) {
        setFromNotification(notification)
        endFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
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
