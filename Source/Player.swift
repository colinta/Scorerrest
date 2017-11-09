////
///  Player.swift
//


class Player: NSObject, NSCoding {
    let name: String
    var scores: [Int] = []
    var score: Int { return scores.reduce(0, +) }

    init(name: String) {
        if name == "" {
            self.name = "\(NSUUID())"
        }
        else {
            self.name = name
        }
    }

    func append(_ score: Int) {
        scores.append(score)
    }

    func clone() -> Player {
        let copy = Player(name: name)
        copy.scores = scores
        return copy
    }

    required init(coder: NSCoder) {
        guard
            let name = coder.decodeObject(forKey: "name") as? String,
            let scores = coder.decodeObject(forKey: "scores") as? [Int]
        else {
            self.name = "\(NSUUID())"
            self.scores = [0]
            return
        }

        self.name = name == "" ? "\(NSUUID())" : name
        self.scores = scores.map { Int($0) }
    }

    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(scores, forKey: "scores")
    }

}
