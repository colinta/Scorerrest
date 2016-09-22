////
///  Player.swift
//


class Player {
    let name: String
    var scores: [Int] = []
    var score: Int { return scores.reduce(0, +) }

    init(name: String) {
        self.name = name
    }

    func append(_ score: Int) {
        scores.append(score)
    }

    func copy() -> Player {
        let copy = Player(name: name)
        copy.scores = scores
        return copy
    }
}
