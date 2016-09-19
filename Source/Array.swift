////
///  Array.swift
//


extension Sequence {

    func any(_ test: (_ el: Iterator.Element) -> Bool) -> Bool {
        for ob in self {
            if test(ob) {
                return true
            }
        }
        return false
    }

    func all(_ test: (_ el: Iterator.Element) -> Bool) -> Bool {
        for ob in self {
            if !test(ob) {
                return false
            }
        }
        return true
    }

}
