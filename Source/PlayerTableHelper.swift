////
///  PlayerTableHelper.swift
//

class PlayerTableHelper: NSObject {
    weak var delegate: MainScreen?
    weak var table: UITableView!
    var allPlayers: [String] = [] {
        didSet {
            table.reloadData()
        }
    }
    var activePlayers: [Player] = [] {
        didSet {
            savedPlayers = activePlayers.enumerated().map { ($0 + 1, $1.name) }
        }
    }
    var savedPlayers: [(Int, String)] = []
}

extension PlayerTableHelper: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPlayers.count + 1
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < allPlayers.count
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var newPlayers: [String] = []
            for (index, name) in allPlayers.enumerated() {
                if index == indexPath.row {
                    savedPlayers = savedPlayers.filter { $0.1 != name }
                }
                else {
                    newPlayers.append(name)
                }
            }
            var order = 0
            savedPlayers = savedPlayers.sorted(by: { $0.0 < $1.0 }).map { _, name in
                order += 1
                return (order, name)
            }
            allPlayers = newPlayers
            table.reloadData()
            delegate?.allPlayersUpdated(allPlayers: allPlayers)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        if indexPath.row == allPlayers.count {
            cell.textLabel?.textColor = .gray
            cell.textLabel?.text = "New Player"
        }
        else {
            cell.textLabel?.textColor = .black
            let name = allPlayers[indexPath.row]
            var text = name
            for (index, player) in savedPlayers {
                if player == name {
                    text = "\(index). \(name)"
                    break
                }
            }
            cell.textLabel?.text = text
        }
        return cell
    }
}

extension PlayerTableHelper: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if indexPath.row == allPlayers.count {
            let alert = UIAlertView(title: "New Player", message: "",
                delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
            alert.alertViewStyle = .plainTextInput
            alert.show()
        }
        else {
            let name = allPlayers[indexPath.row]
            cell?.isSelected = false
            var found = false
            var players: [(Int, String)] = []
            var newIndex = 1
            for (_, player) in savedPlayers.sorted(by: { $0.0 < $1.0 }) {
                if player == name {
                    found = true
                }
                else {
                    players.append((newIndex, player))
                    newIndex += 1
                }
            }

            if found {
                savedPlayers = players
                cell?.textLabel?.text = name
                table.reloadData()
            }
            else {
                let index = savedPlayers.count + 1
                savedPlayers.append((index, name))
                cell?.textLabel?.text = "\(index). \(name)"
            }
        }
    }
}

extension PlayerTableHelper: UIAlertViewDelegate {

    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1, let name = alertView.textField(at: 0)?.text
        , !name.isEmpty && !allPlayers.contains(name)
        {
            allPlayers.append(name)
            table.reloadData()
            delegate?.allPlayersUpdated(allPlayers: allPlayers)
        }
    }
}
