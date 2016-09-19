////
///  MainScreen.swift
//

import SnapKit


class MainScreen: Screen {
    enum Priority: ConstraintPriorityTarget {
        case Low
        case Medium
        case High
        case Required

        var constraintPriorityTargetValue: Float {
            switch self {
            case .Low: return UILayoutPriorityDefaultLow
            case .Medium: return (UILayoutPriorityDefaultHigh + UILayoutPriorityDefaultLow) / 2
            case .High: return UILayoutPriorityDefaultHigh
            case .Required: return UILayoutPriorityRequired
            }
        }

    }
    struct Size {
        static let margin: CGFloat = 5
        static let buttonContainerMaxWidth: CGFloat = 400
        static let currentScoreMaxWidth: CGFloat = 260
        static let bottomMargin: CGFloat = 10
        static let buttonOverlap: CGFloat = 5
        static let gradientWidth: CGFloat = 30
        static let highlightedSize = CGSize(width: 90, height: 50)
        static let tableMargins = UIEdgeInsets(top: 90, left: 20, bottom: 45, right: 20)
    }

    var allPlayers: [String] = [] {
        didSet {
            playerTable.reloadData()
        }
    }
    var savedPlayers: [(Int, String)] = []
    var activePlayers: [Player] = [] {
        didSet {
            updateNameViews()
            updateHighlight()
        }
    }
    var currentPlayer: Int = 0 {
        didSet { updateHighlight() }
    }
    var mem: String? {
        get { return memFeed.text }
        set { memFeed.text = newValue}
    }
    var currentScore: String? {
        get { return currentScoreView.text }
        set { currentScoreView.text = newValue ?? "0" }
    }
    weak var delegate: MainViewController?

    fileprivate let namesView = UIScrollView()
    fileprivate var scoreViews: [UILabel] = []
    fileprivate var playerButtons: [UIButton] = []

    fileprivate let highlightedNameView = UIView()
    fileprivate var highlightedLeading: Constraint?
    fileprivate let addPlayerButton = UIButton()
    fileprivate var addPlayerLeading: Constraint?

    fileprivate let scoreboardView = UIScrollView()
    fileprivate var scoreboardTrailing: Constraint?
    fileprivate let buttonContainer = UIView()
    fileprivate var buttonContainerWidth: Constraint?

    fileprivate let currentScoreView = DigitalView()
    fileprivate let clearButton = StyledButton(.gray, text: "C")
    fileprivate let keypadButton = StyledButton(.gray, text: "123")
    fileprivate let signButton = StyledButton(.red, text: "+/–")
    fileprivate let okButton = StyledButton(.green, text: "OK")
    fileprivate let memButton = StyledButton(.green, text: "M+")
    fileprivate let minusFiveButton = StyledButton(.minusFive, text: "–5")
    fileprivate let minusOneButton = StyledButton(.minusOne, text: "–")
    fileprivate let plusOneButton = StyledButton(.plusOne, text: "+")
    fileprivate let plusFiveButton = StyledButton(.plusFive, text: "+5")
    fileprivate let memFeed = UILabel()
    fileprivate let memView = UIScrollView()
    fileprivate var memViewWidth: Constraint?
    fileprivate var memViewHeight: Constraint?

    fileprivate let overlay = UIView()
    fileprivate let overlayBg = UIView()
    fileprivate let playerTable = UITableView()

    override func style() {
        let scoreboardColor = UIColor(patternImage: UIImage(named: "notepad")!)
        scoreboardView.backgroundColor = scoreboardColor
        addPlayerButton.setTitle("+", for: .normal)
        addPlayerButton.setTitleColor(.white, for: .normal)
        addPlayerButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        addPlayerButton.backgroundColor = UIColor(hex: 0x70B304)
        addPlayerButton.titleEdgeInsets.bottom = 4
        addPlayerButton.layer.cornerRadius = 5
        highlightedNameView.backgroundColor = .yellow
        highlightedNameView.isHidden = true
        minusFiveButton.titleEdgeInsets.right = Size.buttonOverlap
        plusFiveButton.titleEdgeInsets.right = Size.buttonOverlap
        signButton.isHidden = true
        memFeed.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        memFeed.textAlignment = .right
        memView.showsVerticalScrollIndicator = false
        memView.showsHorizontalScrollIndicator = false
        namesView.showsVerticalScrollIndicator = false
        namesView.showsHorizontalScrollIndicator = false

        let overlayColor = UIColor(patternImage: UIImage(named: "overlay")!)
        overlayBg.backgroundColor = overlayColor
        overlayBg.alpha = 0.8
        overlay.isHidden = true
        overlay.alpha = 0

        playerTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func bindActions() {
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        keypadButton.addTarget(self, action: #selector(keypadTapped), for: .touchUpInside)
        signButton.addTarget(self, action: #selector(signTapped), for: .touchUpInside)
        okButton.addTarget(self, action: #selector(okTapped), for: .touchUpInside)
        memButton.addTarget(self, action: #selector(memTapped), for: .touchUpInside)
        minusFiveButton.addTarget(self, action: #selector(minusFiveTapped), for: .touchUpInside)
        minusOneButton.addTarget(self, action: #selector(minusOneTapped), for: .touchUpInside)
        plusOneButton.addTarget(self, action: #selector(plusOneTapped), for: .touchUpInside)
        plusFiveButton.addTarget(self, action: #selector(plusFiveTapped), for: .touchUpInside)
        addPlayerButton.addTarget(self, action: #selector(addPlayerTapped), for: .touchUpInside)
        scoreboardView.delegate = self
        namesView.delegate = self
        playerTable.dataSource = self
        playerTable.delegate = self

        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(hideOverlay))
        overlayBg.addGestureRecognizer(gesture)
    }

    override func arrange() {
        addSubview(namesView)
        addSubview(scoreboardView)
        addSubview(buttonContainer)
        addSubview(overlay)

        namesView.addSubview(highlightedNameView)
        namesView.addSubview(addPlayerButton)

        buttonContainer.addSubview(currentScoreView)
        buttonContainer.addSubview(clearButton)
        buttonContainer.addSubview(keypadButton)
        buttonContainer.addSubview(signButton)
        buttonContainer.addSubview(okButton)
        buttonContainer.addSubview(memButton)
        buttonContainer.addSubview(minusFiveButton)
        buttonContainer.addSubview(plusFiveButton)
        buttonContainer.addSubview(minusOneButton)
        buttonContainer.addSubview(plusOneButton)
        buttonContainer.addSubview(memView)

        memView.addSubview(memFeed)

        overlay.addSubview(overlayBg)
        overlay.addSubview(playerTable)

        namesView.snp.makeConstraints { make in
            make.top.equalTo(self).offset(20)
            make.leading.trailing.equalTo(self)
            make.height.equalTo(Size.highlightedSize.height)
        }
        highlightedNameView.snp.makeConstraints { make in
            make.top.bottom.equalTo(namesView)
            make.size.equalTo(Size.highlightedSize)
        }
        addPlayerButton.snp.makeConstraints { make in
            make.width.top.bottom.equalTo(highlightedNameView)
            addPlayerLeading = make.leading.equalTo(namesView).constraint
            make.trailing.equalTo(namesView)
        }
        scoreboardView.snp.makeConstraints { make in
            make.top.equalTo(namesView.snp.bottom)
            make.leading.trailing.equalTo(self)
            make.bottom.equalTo(buttonContainer.snp.top)
            // make.bottom.equalTo(self)
        }

        buttonContainer.snp.makeConstraints { make in
            make.width.equalTo(self).priority(Priority.Medium)
            make.width.lessThanOrEqualTo(Size.buttonContainerMaxWidth).priority(Priority.High)
            // make.bottom.centerX.equalTo(keyboardAnchor.snp.top)
            make.bottom.centerX.equalTo(self)
            make.top.lessThanOrEqualTo(currentScoreView.snp.top)
            make.top.lessThanOrEqualTo(memButton.snp.top)
            make.top.lessThanOrEqualTo(clearButton.snp.top)
        }
        let buttonContainerWidthAnchor = UIView()
        buttonContainer.addSubview(buttonContainerWidthAnchor)
        buttonContainerWidthAnchor.snp.makeConstraints { make in
            buttonContainerWidth = make.width.equalTo(frame.size.width).priority(Priority.Required).constraint
            make.leading.trailing.equalTo(buttonContainer)
        }

        currentScoreView.snp.makeConstraints { make in
            make.top.equalTo(buttonContainer).offset(Size.margin)
            make.width.lessThanOrEqualTo(Size.currentScoreMaxWidth).priority(Priority.High)
            make.centerX.equalTo(buttonContainer)
            make.bottom.equalTo(memView.snp.top).offset(-Size.margin)
        }
        keypadButton.snp.makeConstraints { make in
            make.leading.equalTo(buttonContainer).offset(Size.margin)
            make.bottom.equalTo(buttonContainer).offset(-Size.bottomMargin)
        }
        clearButton.snp.makeConstraints { make in
            make.leading.equalTo(buttonContainer).offset(Size.margin)
            make.bottom.equalTo(keypadButton.snp.top).offset(-Size.margin)
        }
        signButton.snp.makeConstraints { make in
            make.leading.equalTo(buttonContainer).offset(Size.margin)
            make.bottom.equalTo(buttonContainer).offset(-Size.bottomMargin)
        }
        okButton.snp.makeConstraints { make in
            make.trailing.equalTo(buttonContainer).offset(-Size.margin)
            make.bottom.equalTo(buttonContainer).offset(-Size.bottomMargin)
        }
        memButton.snp.makeConstraints { make in
            make.trailing.equalTo(buttonContainer).offset(-Size.margin)
            make.bottom.equalTo(okButton.snp.top).offset(-Size.bottomMargin)
        }

        minusFiveButton.snp.makeConstraints { make in
            make.centerY.equalTo(okButton)
            make.trailing.equalTo(minusOneButton.snp.leading).offset(Size.buttonOverlap)
        }
        minusOneButton.snp.makeConstraints { make in
            make.centerY.equalTo(okButton)
            make.trailing.equalTo(buttonContainer.snp.centerX)
        }
        plusOneButton.snp.makeConstraints { make in
            make.centerY.equalTo(okButton)
            make.leading.equalTo(buttonContainer.snp.centerX)
        }
        plusFiveButton.snp.makeConstraints { make in
            make.centerY.equalTo(okButton)
            make.leading.equalTo(plusOneButton.snp.trailing).offset(-Size.buttonOverlap)
        }
        let memViewSizeAnchor = UIView()
        memView.addSubview(memViewSizeAnchor)
        memViewSizeAnchor.snp.makeConstraints { make in
            memViewWidth = make.width.equalTo(memView.frame.width).priority(Priority.Required).constraint
            memViewHeight = make.width.equalTo(memView.frame.height).priority(Priority.Required).constraint
            make.top.bottom.trailing.equalTo(memView)
            make.leading.greaterThanOrEqualTo(memView)
        }
        memView.snp.makeConstraints { make in
            make.leading.equalTo(clearButton.snp.trailing).offset(Size.margin)
            make.trailing.equalTo(memButton.snp.leading).offset(-Size.margin)
            make.centerY.height.equalTo(clearButton)
        }
        memFeed.snp.makeConstraints { make in
            make.edges.equalTo(memView).inset(Size.margin).priority(Priority.High)
        }
        memFeed.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .horizontal)
        memFeed.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .vertical)

        overlay.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        overlayBg.snp.makeConstraints { make in
            make.edges.equalTo(overlay)
        }
        playerTable.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(overlay).inset(Size.tableMargins)
            make.bottom.equalTo(overlay).offset(-Size.tableMargins.bottom).priority(Priority.Medium)
            make.bottom.equalTo(keyboardAnchor.snp.top).offset(-Size.tableMargins.bottom).priority(Priority.Required)
        }
    }

    override func layoutSubviews() {
        buttonContainerWidth?.update(offset: frame.width)
        memViewWidth?.update(offset: memView.frame.width)
        memViewHeight?.update(offset: memView.frame.height)
        super.layoutSubviews()
    }
}

extension MainScreen {
    func updateScores() {
        let normal: [String: AnyObject] = [
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 14)!,
            NSForegroundColorAttributeName: UIColor.black,
        ]
        let underlined: [String: AnyObject] = [
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 14)!,
            NSForegroundColorAttributeName: UIColor.black,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle as AnyObject,
        ]
        for (index, player) in activePlayers.enumerated() {
            let playerView = playerButtons[index]
            playerView.setTitle(player.name + "\n\(player.score)", for: .normal)
            let scoreboardLabel = scoreViews[index]

            let scoreText = NSMutableAttributedString()
            var first = true
            var total = 0
            for score in player.scores {
                total += score
                if first {
                    scoreText.append(NSAttributedString(string: "\(score)\n", attributes: normal))
                }
                else {
                    let scoreString: String = (score >= 0 ? "+ \(score)" : "- \(-score)")
                    scoreText.append(NSAttributedString(string: scoreString, attributes: underlined))
                    scoreText.append(NSAttributedString(string: "\n\(total)\n", attributes: normal))
                }

                first = false
            }
            scoreboardLabel.attributedText = scoreText
        }
        layoutIfNeeded()
        var contentOffset = scoreboardView.contentOffset
        contentOffset.y = max(0, scoreboardView.contentSize.height - scoreboardView.frame.height)
        scoreboardView.setContentOffset(contentOffset, animated: true)
    }
}

extension MainScreen: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == namesView {
            scoreboardView.contentOffset.x = namesView.contentOffset.x
        }
        else {
            namesView.contentOffset.x = scoreboardView.contentOffset.x
        }
    }
}

extension MainScreen {
    fileprivate func updateNameViews() {
        for view in playerButtons {
            view.removeFromSuperview()
        }
        for view in scoreViews {
            view.removeFromSuperview()
        }

        var prevView: UIView?
        var prevScore: UIView?
        playerButtons = []
        scoreViews = []
        for player in activePlayers {
            let box = UIButton()
            box.setTitle(player.name + "\n\(player.score)", for: .normal)
            box.setTitleColor(.black, for: .normal)
            box.titleLabel!.numberOfLines = 2
            box.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
            box.titleLabel!.textAlignment = .center
            box.titleLabel!.adjustsFontSizeToFitWidth = true
            box.titleLabel!.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .horizontal)
            box.titleLabel!.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .vertical)

            playerButtons.append(box)
            namesView.addSubview(box)
            box.addTarget(self, action: #selector(playerTapped(_:)), for: .touchUpInside)

            box.snp.makeConstraints { make in
                make.top.equalTo(namesView)
                make.size.equalTo(highlightedNameView)

                if let prevView = prevView {
                    make.leading.equalTo(prevView.snp.trailing)
                }
                else {
                    make.leading.equalTo(namesView)
                }
            }

            prevView = box

            let score = UILabel()
            score.textAlignment = .right
            score.font = UIFont(name: "HelveticaNeue-Light", size: 14)
            score.numberOfLines = 0
            scoreViews.append(score)
            scoreboardView.addSubview(score)

            score.snp.makeConstraints { make in
                make.top.equalTo(scoreboardView)
                make.bottom.lessThanOrEqualTo(scoreboardView)
                if let prevScore = prevScore {
                    make.leading.equalTo(prevScore.snp.trailing).offset(Size.margin)
                }
                else {
                    make.leading.equalTo(scoreboardView).offset(Size.margin)
                }
                make.width.equalTo(Size.highlightedSize.width - Size.margin)
            }

            prevScore = score
        }

        addPlayerLeading?.deactivate()
        addPlayerButton.snp.makeConstraints { make in
            if let prevView = prevView {
                addPlayerLeading = make.leading.equalTo(prevView.snp.trailing).constraint
            }
            else {
                addPlayerLeading = make.leading.equalTo(namesView).constraint
            }
        }

        scoreboardTrailing?.deactivate()
        if let prevScore = prevScore {
            scoreboardView.snp.makeConstraints { make in
                scoreboardTrailing = make.trailing.equalTo(prevScore.snp.trailing).constraint
            }
        }

        updateScores()
    }

    fileprivate func updateHighlight() {
        highlightedNameView.isHidden = activePlayers.count == 0

        highlightedLeading?.deactivate()
        highlightedNameView.snp.makeConstraints { make in
            if currentPlayer < playerButtons.count {
                highlightedLeading = make.leading.equalTo(playerButtons[currentPlayer]).constraint
            }
            else {
                highlightedLeading = nil
            }
        }
        // layoutIfNeeded()
        namesView.scrollRectToVisible(highlightedNameView.frame, animated: true)
    }
}

// MARK: Actions
extension MainScreen {
    func clearTapped() {
        delegate?.clearTapped()
    }

    func keypadTapped() {
        delegate?.keypadTapped()
    }

    func signTapped() {
        delegate?.signTapped()
    }

    func playerTapped(_ sender: UIButton) {
        if let index = playerButtons.index(of: sender) {
            currentPlayer = index
        }
    }

    func okTapped() {
        delegate?.okTapped()
    }

    func memTapped() {
        delegate?.memTapped()
    }

    func minusFiveTapped() {
        delegate?.minusFiveTapped()
    }

    func minusOneTapped() {
        delegate?.minusOneTapped()
    }

    func plusOneTapped() {
        delegate?.plusOneTapped()
    }

    func plusFiveTapped() {
        delegate?.plusFiveTapped()
    }

    func addPlayerTapped() {
        delegate?.addPlayerTapped()
    }
}

extension MainScreen {
    func showOverlay() {
        savedPlayers = activePlayers.enumerated().map { ($0 + 1, $1.name) }
        playerTable.reloadData()
        overlay.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.overlay.alpha = 1
        }
    }

    func hideOverlay() {
        activePlayers = savedPlayers.sorted(by: { $0.0 < $1.0 }).map { _, name in
            for player in activePlayers {
                if player.name == name {
                    return player
                }
            }
            return Player(name: name)
        }

        UIView.animate(withDuration: 0.3, animations: {
            self.overlay.alpha = 0
        }, completion: { _ in
            self.overlay.isHidden = true
        })
    }
}

extension MainScreen: UITableViewDataSource {
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
            allPlayers = newPlayers
            playerTable.reloadData()
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

extension MainScreen: UITableViewDelegate {
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
                playerTable.reloadData()
            }
            else {
                let index = savedPlayers.count + 1
                savedPlayers.append((index, name))
                cell?.textLabel?.text = "\(index). \(name)"
            }
        }
    }
}

extension MainScreen: UIAlertViewDelegate {

    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1, let name = alertView.textField(at: 0)?.text
        , !name.characters.isEmpty && !allPlayers.contains(name)
        {
            allPlayers.append(name)
            playerTable.reloadData()
        }
    }
}
