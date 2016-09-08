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

public func postNotification<A>(note: TypedNotification<A>, value: A) {
    let userInfo = ["value": Box(value)]
    NSNotificationCenter.defaultCenter().postNotificationName(note.name, object: nil, userInfo: userInfo)
}

public class NotificationObserver {
    let observer: NSObjectProtocol

    public init<A>(notification: TypedNotification<A>, block aBlock: A -> Void) {
        observer = NSNotificationCenter.defaultCenter().addObserverForName(notification.name, object: nil, queue: nil) { note in
            if let value = (note.userInfo?["value"] as? Box<A>)?.value {
                aBlock(value)
            } else {
                assert(false, "Couldn't understand user info")
            }
        }
    }

    public func removeObserver() {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }

    deinit {
        removeObserver()
    }

}
