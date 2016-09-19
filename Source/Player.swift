////
///  Player.swift
//


class Player {
    let name: String
    var scores: [Int] = []
    var score: Int { return scores.reduce(0, combine: +) }

    init(name: String) {
        self.name = name
    }

    func append(score: Int) {
        scores.append(score)
    }
}
