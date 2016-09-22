////
///  IntExtensions.swift
//

extension Int {
    var localized: String {
        return NumberFormatter.localizedString(from: NSNumber(value: self), number: .decimal)
    }
}
