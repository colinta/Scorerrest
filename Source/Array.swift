////
///  Array.swift
//


extension SequenceType {

    func any(@noescape test: (el: Generator.Element) -> Bool) -> Bool {
        for ob in self {
            if test(el: ob) {
                return true
            }
        }
        return false
    }

    func all(test: (el: Generator.Element) -> Bool) -> Bool {
        for ob in self {
            if !test(el: ob) {
                return false
            }
        }
        return true
    }

}
