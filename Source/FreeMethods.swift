////
///  FreeMethods.swift
//

import UIKit


typealias Block = (() -> Void)
typealias TakesIndexBlock = ((Int) -> Void)


func times(_ times: Int, block: Block) {
    times_(times) { (index: Int) in block() }
}

func times(_ times: Int, block: TakesIndexBlock) {
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

func isX() -> Bool {
    return UIScreen.main.bounds.size.height == 812
}
