////
///  ScoresTableHelper.swift
//

class ScoresTableHelper: NSObject {
    weak var delegate: MainScreen?
    weak var table: UITableView!
    var selectedRow: Int?
    var scores: [Int] = [] {
        didSet {
            table.reloadData()
        }
    }
}

extension ScoresTableHelper: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < scores.count
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var newScores: [Int] = []
            for (index, score) in scores.enumerated() where index != indexPath.row {
                newScores.append(score)
            }
            scores = newScores
            table.reloadData()
            delegate?.scoresUpdated(scores: scores)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        cell.textLabel?.textColor = .black
        let score = scores[indexPath.row]
        let text = score.localized
        cell.textLabel?.text = text
        return cell
    }
}

extension ScoresTableHelper: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        selectedRow = indexPath.row
        cell?.isSelected = false
        let alert = UIAlertView(title: "Edit", message: "",
            delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        alert.alertViewStyle = .plainTextInput
        if let textField = alert.textField(at: 0) {
            let score = scores[indexPath.row]
            textField.text = "\(score)"
        }
        alert.show()
    }
}

extension ScoresTableHelper: UIAlertViewDelegate {

    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1,
            let text = alertView.textField(at: 0)?.text,
            let score = Int(text),
            let selectedRow = selectedRow
        {
            scores[selectedRow] = score
            table.reloadData()
            delegate?.scoresUpdated(scores: scores)
        }
    }
}
