////
///  MainViewController.swift
//

class MainViewController: UIViewController {
    struct State {
        let activePlayers: [Player]
        let currentPlayer: Int
        let currentScore: Int
        let mem: [Int]
    }

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
            screen.currentScore = currentScore
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
                str += val.localized
                total += val
            }
            screen.mem = "\(str) = \(total.localized)"
        }
    }
    var state: [State] = []

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

        screen.activePlayers = [
        ]
    }
}

// MARK: State

extension MainViewController {
    func pushState() {
        state.append(State(
            activePlayers: activePlayers.map { $0.copy() },
            currentPlayer: currentPlayer,
            currentScore: currentScore,
            mem: mem
            ))
        screen.undoEnabled = true
    }

    func popState() {
        if let last = state.popLast() {
            activePlayers = last.activePlayers
            currentPlayer = last.currentPlayer
            currentScore = last.currentScore
            mem = last.mem
        }

        screen.undoEnabled = state.count > 0
    }
}

// MARK: Actions

extension MainViewController {
    func restartTapped() {
        screen.activePlayers = screen.activePlayers.map { Player(name: $0.name) }
        state = []
        mem = []
        currentScore = 0
        screen.undoEnabled = false
    }

    func undoTapped() {
        popState()
    }

    func clearTapped() {
        mem = []
        currentScore = 0
    }

    func signTapped() {
        currentScore = -currentScore
    }

    func concat(number: String) {
        if let score = Int("\(currentScore)\(number)") {
            currentScore = score
        }
    }

    func okTapped() {
        guard currentPlayer < activePlayers.count else { return }

        pushState()
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
        screen.showPlayers()
    }

    func activePlayersWillUpdate() {
        if screen.activePlayers.count != 0 {
            pushState()
        }
    }

    func allPlayersUpdate(_ players: [String]) {
        UserDefaults.standard.set(players, forKey: "allPlayers")
    }
}
