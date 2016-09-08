////
///  UIWindowExtensions.swift
//

extension UIWindow {
    class var mainWindow: UIWindow {
        return UIApplication.sharedApplication().keyWindow ?? UIWindow()
    }
}
