////
///  MainViewController.swift
//

class MainViewController: UIViewController {
    var screen: MainScreen { return self.view as! MainScreen }
    var activePlayers: [Player] {
        get { return screen.activePlayers }
        set { screen.activePlayers = newValue }
    }
    var currentPlayer: Int {
        get { return screen.currentPlayer }
        set { screen.currentPlayer = newValue }
    }
    var currentScore: Int = 0 {
        didSet {
            screen.currentScore = "\(currentScore)"
        }
    }
    var mem: [Int] = [] {
        didSet {
            guard mem.count > 0 else {
                screen.mem = ""
                return
            }

            var str = ""
            var total: Int = 0
            for val in mem {
                if val >= 0 {
                    str += "+"
                }
                str += "\(val)"
                total += val
            }
            screen.mem = "\(str) = \(total)"
        }
    }

    override func loadView() {
        let screen = MainScreen()
        screen.delegate = self
        view = screen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let allPlayers = UserDefaults.standard.object(forKey: "allPlayers") as? [String] {
            screen.allPlayers = allPlayers
            if allPlayers.count >= 2 {
                screen.activePlayers = [Player(name: allPlayers[0]), Player(name: allPlayers[1])]
            }
        }
        else {
            screen.allPlayers = [
                "Mr. White", "Mr. Blue", "Mr. Pink"
            ]
            screen.activePlayers = []
        }

        screen.allPlayers = [
            "", ""
        ]
        screen.activePlayers = [
            Player(name: ""), Player(name: "")
        ]
    }
}

// MARK: Actions

extension MainViewController {
    func clearTapped() {
        mem = []
        currentScore = 0
    }

    func keypadTapped() {
        print("keypadTapped")
    }

    func signTapped() {
        print("signTapped")
    }

    func okTapped() {
        guard currentPlayer < activePlayers.count else { return }

        let total = mem.reduce(0, +) + currentScore
        activePlayers[currentPlayer].append(total)
        currentPlayer = (currentPlayer + 1) % activePlayers.count
        screen.updateScores()

        mem = []
        currentScore = 0
    }

    func memTapped() {
        mem.append(currentScore)
        currentScore = 0
    }

    func minusFiveTapped() {
        currentScore -= 5
    }

    func minusOneTapped() {
        currentScore -= 1
    }

    func plusOneTapped() {
        currentScore += 1
    }

    func plusFiveTapped() {
        currentScore += 5
    }

    func addPlayerTapped() {
        screen.showOverlay()
    }

    func allPlayersUpdate(_ players: [String]) {
        UserDefaults.standard.set(players, forKey: "allPlayers")
    }
}
