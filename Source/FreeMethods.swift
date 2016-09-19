////
///  FreeMethods.swift
//

import UIKit

private var isTesting = false


#if DEBUG
func log(message: String) {
    print(message)
}
#else
func log(_ message: String) {}
#endif


// MARK: Animations

public struct AnimationOptions {
    let duration: TimeInterval
    let delay: TimeInterval
    let options: UIViewAnimationOptions
    let completion: ((Bool) -> Void)?
}

public let DefaultAnimationDuration: TimeInterval = 0.2
public let DefaultAppleAnimationDuration: TimeInterval = 0.3
public func animate(duration: TimeInterval = DefaultAnimationDuration, delay: TimeInterval = 0, options: UIViewAnimationOptions = UIViewAnimationOptions(), animated: Bool? = nil, completion: ((Bool) -> Void)? = nil, animations: @escaping () -> Void) {
    let shouldAnimate: Bool = animated ?? true
    let options = AnimationOptions(duration: duration, delay: delay, options: options, completion: completion)
    animate(options, animated: shouldAnimate, animations: animations)
}

public func animate(_ options: AnimationOptions, animated: Bool = true, animations: @escaping () -> Void) {
    if animated {
        UIView.animate(withDuration: options.duration, delay: options.delay, options: options.options, animations: animations, completion: options.completion)
    }
    else {
        animations()
        options.completion?(true)
    }
}


// MARK: Async, Timed, and Throttled closures

public typealias BasicBlock = (() -> Void)
public typealias ThrottledBlock = ((@escaping BasicBlock) -> Void)
public typealias CancellableBlock = (Bool) -> Void
public typealias TakesIndexBlock = ((Int) -> Void)


open class Proc {
    var block: BasicBlock

    public init(_ block: @escaping BasicBlock) {
        self.block = block
    }

    @objc
    func run() {
        block()
    }
}


public func times(_ times: Int, block: BasicBlock) {
    times_(times) { (index: Int) in block() }
}

public func times(_ times: Int, block: TakesIndexBlock) {
    times_(times, block: block)
}

private func times_(_ times: Int, block: TakesIndexBlock) {
    if times <= 0 {
        return
    }
    for i in 0 ..< times {
        block(i)
    }
}

public func after(_ times: Int, block: @escaping BasicBlock) -> BasicBlock {
    if times == 0 {
        block()
        return {}
    }

    var remaining = times
    return {
        remaining -= 1
        if remaining == 0 {
            block()
        }
    }
}

public func until(_ times: Int, block: @escaping BasicBlock) -> BasicBlock {
    if times == 0 {
        return {}
    }

    var remaining = times
    return {
        remaining -= 1
        if remaining >= 0 {
            block()
        }
    }
}

public func once(_ block: @escaping BasicBlock) -> BasicBlock {
    return until(1, block: block)
}

public func inBackground(_ block: @escaping BasicBlock) {
    if isTesting {
        block()
    }
    else {
        DispatchQueue.global().async(execute: block)
    }
}

public func inForeground(_ block: @escaping BasicBlock) {
    nextTick(block)
}

public func nextTick(_ block: @escaping BasicBlock) {
    if isTesting {
        if Thread.isMainThread {
            block()
        }
        else {
            DispatchQueue.main.sync(execute: block)
        }
    }
    else {
        nextTick(on: DispatchQueue.main, block: block)
    }
}

public func nextTick(on: DispatchQueue, block: @escaping BasicBlock) {
    on.async(execute: block)
}

public func timeout(_ duration: TimeInterval, block: @escaping BasicBlock) -> BasicBlock {
    let handler = once(block)
    _ = delay(duration) {
        handler()
    }
    return handler
}

public func delay(_ duration: TimeInterval, background: Bool = false, block: @escaping BasicBlock) {
    let killTimeOffset = Int64(CDouble(duration) * CDouble(NSEC_PER_SEC))
    let killTime = DispatchTime.now() + Double(killTimeOffset) / Double(NSEC_PER_SEC)
    let queue = background ? DispatchQueue.global() : DispatchQueue.main
    queue.asyncAfter(deadline: killTime, execute: block)
}

public func cancelableDelay(_ duration: TimeInterval, block: @escaping BasicBlock) -> BasicBlock {
    let killTimeOffset = Int64(CDouble(duration) * CDouble(NSEC_PER_SEC))
    let killTime = DispatchTime.now() + Double(killTimeOffset) / Double(NSEC_PER_SEC)
    var cancelled = false
    DispatchQueue.main.asyncAfter(deadline: killTime) {
        if !cancelled { block() }
    }
    return { cancelled = true }
}

public func debounce(_ timeout: TimeInterval, block: @escaping BasicBlock) -> BasicBlock {
    var timer: Timer? = nil
    let proc = Proc(block)

    return {
        if let prevTimer = timer {
            prevTimer.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: timeout, target: proc, selector: #selector(Proc.run), userInfo: nil, repeats: false)
    }
}

public func debounce(_ timeout: TimeInterval) -> ThrottledBlock {
    var timer: Timer? = nil

    return { block in
        if let prevTimer = timer {
            prevTimer.invalidate()
        }
        let proc = Proc(block)
        timer = Timer.scheduledTimer(timeInterval: timeout, target: proc, selector: #selector(Proc.run), userInfo: nil, repeats: false)
    }
}

public func throttle(_ interval: TimeInterval, block: @escaping BasicBlock) -> BasicBlock {
    var timer: Timer? = nil
    let proc = Proc() {
        timer = nil
        block()
    }

    return {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: interval, target: proc, selector: #selector(Proc.run), userInfo: nil, repeats: false)
        }
    }
}

public func throttle(_ interval: TimeInterval) -> ThrottledBlock {
    var timer: Timer? = nil
    var lastBlock: BasicBlock?

    return { block in
        lastBlock = block

        if timer == nil {
            let proc = Proc() {
                timer = nil
                lastBlock?()
            }

            timer = Timer.scheduledTimer(timeInterval: interval, target: proc, selector: #selector(Proc.run), userInfo: nil, repeats: false)
        }
    }
}
