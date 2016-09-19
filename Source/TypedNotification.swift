//
//  TypedNotifications.swift
//  Ello
//
//  Created by Sean on 1/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//
//  Thanks to objc.io http://www.objc.io/snippets/16.html
//  Find Here: https://gist.github.com/chriseidhof/9bf7280063db3a249fbe

import Foundation

public struct TypedNotification<A> {
    public let name: String
    public init(name: String) {
        self.name = name
    }
}

public func postNotification<A>(_ note: TypedNotification<A>, value: A) {
    let userInfo = ["value": Box(value)]
    NotificationCenter.default.post(name: Notification.Name(rawValue: note.name), object: nil, userInfo: userInfo)
}

open class NotificationObserver {
    let observer: NSObjectProtocol

    public init<A>(notification: TypedNotification<A>, block aBlock: @escaping (A) -> Void) {
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: notification.name), object: nil, queue: nil) { note in
            if let value = ((note as NSNotification).userInfo?["value"] as? Box<A>)?.value {
                aBlock(value)
            } else {
                assert(false, "Couldn't understand user info")
            }
        }
    }

    open func removeObserver() {
        NotificationCenter.default.removeObserver(observer)
    }

    deinit {
        removeObserver()
    }

}
