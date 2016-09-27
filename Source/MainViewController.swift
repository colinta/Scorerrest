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
    var archivePath: String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent("scorerrest").path
    }

    override func loadView() {
        let screen = MainScreen()
        screen.delegate = self
        view = screen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if !restore() {
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
        }
    }
}

// MARK: State

extension MainViewController {
    func currentState() -> State {
        return State(
            activePlayers: activePlayers.map { $0.clone() },
            currentPlayer: currentPlayer,
            currentScore: currentScore,
            mem: mem
        )
    }

    func pushState() {
        state.append(currentState())
        screen.undoEnabled = true
        save()
    }

    func popState(save: Bool = true) {
        if let last = state.popLast() {
            activePlayers = last.activePlayers
            currentPlayer = last.currentPlayer
            currentScore = last.currentScore
            mem = last.mem
        }

        screen.undoEnabled = state.count > 0
        if save {
            self.save()
        }
    }

    func save() {
        let path = archivePath
        NSKeyedArchiver.archiveRootObject(state + [currentState()], toFile: path)
    }

    func restore() -> Bool {
        let path = archivePath
        if let archive = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [State] {
            state = archive
            popState(save: false)
            return true
        }
        return false
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
        save()
    }

    func undoTapped() {
        popState()
    }

    func clearTapped() {
        mem = []
        currentScore = 0
        save()
    }

    func signTapped() {
        currentScore = -currentScore
        save()
    }

    func concat(number: String) {
        if let score = Int("\(currentScore)\(number)") {
            currentScore = score
            save()
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
        save()
    }

    func memTapped() {
        mem.append(currentScore)
        currentScore = 0
        save()
    }

    func minusFiveTapped() {
        currentScore -= 5
        save()
    }

    func minusOneTapped() {
        currentScore -= 1
        save()
    }

    func plusOneTapped() {
        currentScore += 1
        save()
    }

    func plusFiveTapped() {
        currentScore += 5
        save()
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
