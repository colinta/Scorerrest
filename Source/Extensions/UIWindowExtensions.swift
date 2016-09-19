////
///  UIWindowExtensions.swift
//

extension UIWindow {
    class var mainWindow: UIWindow {
        return UIApplication.shared.keyWindow ?? UIWindow()
    }
}
