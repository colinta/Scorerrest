////
///  Archive.swift
//


class State: NSObject, NSCoding {
    let activePlayers: [Player]
    let currentPlayer: Int
    let currentScore: Int
    let mem: [Int]

    init(activePlayers: [Player], currentPlayer: Int, currentScore: Int, mem: [Int]) {
        self.activePlayers = activePlayers
        self.currentPlayer = currentPlayer
        self.currentScore = currentScore
        self.mem = mem
    }


    required init(coder: NSCoder) {
        guard
            let activePlayers = coder.decodeObject(forKey: "activePlayers") as? [Player],
            let mem = coder.decodeObject(forKey: "mem") as? [Int]
        else {
            self.activePlayers = []
            self.currentPlayer = 0
            self.currentScore = 0
            self.mem = []
            return
        }
        let currentPlayer = coder.decodeInt64(forKey: "currentPlayer")
        let currentScore = coder.decodeInt64(forKey: "currentScore")

        self.activePlayers = activePlayers
        self.currentPlayer = Int(currentPlayer)
        self.currentScore = Int(currentScore)
        self.mem = mem.map { Int($0) }
    }

    func encode(with coder: NSCoder) {
        coder.encode(activePlayers, forKey: "activePlayers")
        coder.encode(currentPlayer, forKey: "currentPlayer")
        coder.encode(currentScore, forKey: "currentScore")
        coder.encode(mem, forKey: "mem")
    }
}
