////
///  MainScreen.swift
//

import SnapKit

class HighlightedNameView: UIView {}
class ButtonContainer: UIView {}
class ButtonContainerWidthAnchor: UIView {}
class MemViewSizeAnchor: UIView {}

class MainScreen: Screen {
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

    private let namesView = UIScrollView()
    private var scoreViews: [UILabel] = []
    private var playerButtons: [UIButton] = []

    private let highlightedNameView = HighlightedNameView()
    private var highlightedLeading: Constraint?
    private let addPlayerButton = UIButton()
    private var addPlayerLeading: Constraint?

    private let scoreboardView = UIScrollView()
    private var scoreboardTrailing: Constraint?
    private let buttonContainer = ButtonContainer()
    private var buttonContainerWidth: Constraint?

    private let currentScoreView = DigitalView()
    private let clearButton = StyledButton(.gray, text: "C")
    private let keypadButton = StyledButton(.gray, text: "123")
    private let signButton = StyledButton(.red, text: "+/–")
    private let okButton = StyledButton(.green, text: "OK")
    private let memButton = StyledButton(.green, text: "M+")
    private let minusFiveButton = StyledButton(.minusFive, text: "–5")
    private let minusOneButton = StyledButton(.minusOne, text: "–")
    private let plusOneButton = StyledButton(.plusOne, text: "+")
    private let plusFiveButton = StyledButton(.plusFive, text: "+5")
    private let memFeed = UILabel()
    private let memView = UIScrollView()
    private var memViewSize: Constraint?

    private let overlay = UIView()
    private let overlayBg = UIView()
    private let playerTable = UITableView()

    override func style() {
        let scoreboardColor = UIColor(patternImage: UIImage(named: "notepad")!)
        scoreboardView.backgroundColor = scoreboardColor
        addPlayerButton.setTitle("+", forState: .Normal)
        addPlayerButton.setTitleColor(.whiteColor(), forState: .Normal)
        addPlayerButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        addPlayerButton.backgroundColor = UIColor(hex: 0x70B304)
        addPlayerButton.titleEdgeInsets.bottom = 4
        addPlayerButton.layer.cornerRadius = 5
        highlightedNameView.backgroundColor = .yellowColor()
        highlightedNameView.hidden = true
        minusFiveButton.titleEdgeInsets.right = Size.buttonOverlap
        plusFiveButton.titleEdgeInsets.right = Size.buttonOverlap
        signButton.hidden = true
        memFeed.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        memFeed.textAlignment = .Right
        memView.showsVerticalScrollIndicator = false
        memView.showsHorizontalScrollIndicator = false
        namesView.showsVerticalScrollIndicator = false
        namesView.showsHorizontalScrollIndicator = false

        let overlayColor = UIColor(patternImage: UIImage(named: "overlay")!)
        overlayBg.backgroundColor = overlayColor
        overlayBg.alpha = 0.8
        overlay.hidden = true
        overlay.alpha = 0

        playerTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func bindActions() {
        clearButton.addTarget(self, action: #selector(clearTapped), forControlEvents: .TouchUpInside)
        keypadButton.addTarget(self, action: #selector(keypadTapped), forControlEvents: .TouchUpInside)
        signButton.addTarget(self, action: #selector(signTapped), forControlEvents: .TouchUpInside)
        okButton.addTarget(self, action: #selector(okTapped), forControlEvents: .TouchUpInside)
        memButton.addTarget(self, action: #selector(memTapped), forControlEvents: .TouchUpInside)
        minusFiveButton.addTarget(self, action: #selector(minusFiveTapped), forControlEvents: .TouchUpInside)
        minusOneButton.addTarget(self, action: #selector(minusOneTapped), forControlEvents: .TouchUpInside)
        plusOneButton.addTarget(self, action: #selector(plusOneTapped), forControlEvents: .TouchUpInside)
        plusFiveButton.addTarget(self, action: #selector(plusFiveTapped), forControlEvents: .TouchUpInside)
        addPlayerButton.addTarget(self, action: #selector(addPlayerTapped), forControlEvents: .TouchUpInside)
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

        namesView.snp_makeConstraints { make in
            make.top.equalTo(self).offset(20)
            make.leading.trailing.equalTo(self)
            make.height.equalTo(Size.highlightedSize.height)
        }
        highlightedNameView.snp_makeConstraints { make in
            make.top.bottom.equalTo(namesView)
            make.size.equalTo(Size.highlightedSize)
        }
        addPlayerButton.snp_makeConstraints { make in
            make.width.top.bottom.equalTo(highlightedNameView)
            addPlayerLeading = make.leading.equalTo(namesView).constraint
            make.trailing.equalTo(namesView)
        }
        scoreboardView.snp_makeConstraints { make in
            make.top.equalTo(namesView.snp_bottom)
            make.leading.trailing.equalTo(self)
            make.bottom.equalTo(buttonContainer.snp_top)
            // make.bottom.equalTo(self)
        }

        buttonContainer.snp_makeConstraints { make in
            make.width.equalTo(self).priorityMedium()
            make.width.lessThanOrEqualTo(Size.buttonContainerMaxWidth).priorityHigh()
            // make.bottom.centerX.equalTo(keyboardAnchor.snp_top)
            make.bottom.centerX.equalTo(self)
            make.top.lessThanOrEqualTo(currentScoreView.snp_top)
            make.top.lessThanOrEqualTo(memButton.snp_top)
            make.top.lessThanOrEqualTo(clearButton.snp_top)
        }
        let buttonContainerWidthAnchor = ButtonContainerWidthAnchor()
        buttonContainer.addSubview(buttonContainerWidthAnchor)
        buttonContainerWidthAnchor.snp_makeConstraints { make in
            buttonContainerWidth = make.width.equalTo(frame.size.width).priorityRequired().constraint
            make.leading.trailing.equalTo(buttonContainer)
        }

        currentScoreView.snp_makeConstraints { make in
            make.top.equalTo(buttonContainer).offset(Size.margin)
            make.width.lessThanOrEqualTo(Size.currentScoreMaxWidth).priorityHigh()
            make.centerX.equalTo(buttonContainer)
            make.bottom.equalTo(memView.snp_top).offset(-Size.margin)
        }
        keypadButton.snp_makeConstraints { make in
            make.leading.equalTo(buttonContainer).offset(Size.margin)
            make.bottom.equalTo(buttonContainer).offset(-Size.bottomMargin)
        }
        clearButton.snp_makeConstraints { make in
            make.leading.equalTo(buttonContainer).offset(Size.margin)
            make.bottom.equalTo(keypadButton.snp_top).offset(-Size.margin)
        }
        signButton.snp_makeConstraints { make in
            make.leading.equalTo(buttonContainer).offset(Size.margin)
            make.bottom.equalTo(buttonContainer).offset(-Size.bottomMargin)
        }
        okButton.snp_makeConstraints { make in
            make.trailing.equalTo(buttonContainer).offset(-Size.margin)
            make.bottom.equalTo(buttonContainer).offset(-Size.bottomMargin)
        }
        memButton.snp_makeConstraints { make in
            make.trailing.equalTo(buttonContainer).offset(-Size.margin)
            make.bottom.equalTo(okButton.snp_top).offset(-Size.bottomMargin)
        }

        minusFiveButton.snp_makeConstraints { make in
            make.centerY.equalTo(okButton)
            make.trailing.equalTo(minusOneButton.snp_leading).offset(Size.buttonOverlap)
        }
        minusOneButton.snp_makeConstraints { make in
            make.centerY.equalTo(okButton)
            make.trailing.equalTo(buttonContainer.snp_centerX)
        }
        plusOneButton.snp_makeConstraints { make in
            make.centerY.equalTo(okButton)
            make.leading.equalTo(buttonContainer.snp_centerX)
        }
        plusFiveButton.snp_makeConstraints { make in
            make.centerY.equalTo(okButton)
            make.leading.equalTo(plusOneButton.snp_trailing).offset(-Size.buttonOverlap)
        }
        let memViewSizeAnchor = MemViewSizeAnchor()
        memView.addSubview(memViewSizeAnchor)
        memViewSizeAnchor.snp_makeConstraints { make in
            memViewSize = make.size.equalTo(memView.frame.size).priorityRequired().constraint
            make.top.bottom.trailing.equalTo(memView)
            make.leading.greaterThanOrEqualTo(memView)
        }
        memView.snp_makeConstraints { make in
            make.leading.equalTo(clearButton.snp_trailing).offset(Size.margin)
            make.trailing.equalTo(memButton.snp_leading).offset(-Size.margin)
            make.centerY.height.equalTo(clearButton)
        }
        memFeed.snp_makeConstraints { make in
            make.edges.equalTo(memView).inset(Size.margin).priorityHigh()
        }
        memFeed.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
        memFeed.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)

        overlay.snp_makeConstraints { make in
            make.edges.equalTo(self)
        }
        overlayBg.snp_makeConstraints { make in
            make.edges.equalTo(overlay)
        }
        playerTable.snp_makeConstraints { make in
            make.top.leading.trailing.equalTo(overlay).inset(Size.tableMargins)
            make.bottom.equalTo(overlay).offset(-Size.tableMargins.bottom).priorityMedium()
            make.bottom.equalTo(keyboardAnchor.snp_top).offset(-Size.tableMargins.bottom).priorityRequired()
        }
    }

    override func layoutSubviews() {
        buttonContainerWidth?.updateOffset(frame.width)
        memViewSize?.updateOffset(memView.frame.size)
        super.layoutSubviews()
    }
}

extension MainScreen {
    func updateScores() {
        let normal: [String: AnyObject] = [
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 14)!,
            NSForegroundColorAttributeName: UIColor.blackColor(),
        ]
        let underlined: [String: AnyObject] = [
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 14)!,
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
        ]
        for (index, player) in activePlayers.enumerate() {
            let playerView = playerButtons[index]
            playerView.setTitle(player.name + "\n\(player.score)", forState: .Normal)
            let scoreboardLabel = scoreViews[index]

            let scoreText = NSMutableAttributedString()
            var first = true
            var total = 0
            for score in player.scores {
                total += score
                if first {
                    scoreText.appendAttributedString(NSAttributedString(string: "\(score)\n", attributes: normal))
                }
                else {
                    let scoreString: String = (score >= 0 ? "+ \(score)" : "- \(-score)")
                    scoreText.appendAttributedString(NSAttributedString(string: scoreString, attributes: underlined))
                    scoreText.appendAttributedString(NSAttributedString(string: "\n\(total)\n", attributes: normal))
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
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == namesView {
            scoreboardView.contentOffset.x = namesView.contentOffset.x
        }
        else {
            namesView.contentOffset.x = scoreboardView.contentOffset.x
        }
    }
}

extension MainScreen {
    private func updateNameViews() {
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
            box.setTitle(player.name + "\n\(player.score)", forState: .Normal)
            box.setTitleColor(.blackColor(), forState: .Normal)
            box.titleLabel!.numberOfLines = 2
            box.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
            box.titleLabel!.textAlignment = .Center
            box.titleLabel!.adjustsFontSizeToFitWidth = true
            box.titleLabel!.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
            box.titleLabel!.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)

            playerButtons.append(box)
            namesView.addSubview(box)
            box.addTarget(self, action: #selector(playerTapped(_:)), forControlEvents: .TouchUpInside)

            box.snp_makeConstraints { make in
                make.top.equalTo(namesView)
                make.size.equalTo(highlightedNameView)

                if let prevView = prevView {
                    make.leading.equalTo(prevView.snp_trailing)
                }
                else {
                    make.leading.equalTo(namesView)
                }
            }

            prevView = box

            let score = UILabel()
            score.textAlignment = .Right
            score.font = UIFont(name: "HelveticaNeue-Light", size: 14)
            score.numberOfLines = 0
            scoreViews.append(score)
            scoreboardView.addSubview(score)

            score.snp_makeConstraints { make in
                make.top.equalTo(scoreboardView)
                make.bottom.lessThanOrEqualTo(scoreboardView)
                if let prevScore = prevScore {
                    make.leading.equalTo(prevScore.snp_trailing).offset(Size.margin)
                }
                else {
                    make.leading.equalTo(scoreboardView).offset(Size.margin)
                }
                make.width.equalTo(Size.highlightedSize.width - Size.margin)
            }

            prevScore = score
        }

        addPlayerLeading?.uninstall()
        addPlayerButton.snp_makeConstraints { make in
            if let prevView = prevView {
                addPlayerLeading = make.leading.equalTo(prevView.snp_trailing).constraint
            }
            else {
                addPlayerLeading = make.leading.equalTo(namesView).constraint
            }
        }

        scoreboardTrailing?.uninstall()
        if let prevScore = prevScore {
            scoreboardView.snp_makeConstraints { make in
                scoreboardTrailing = make.trailing.equalTo(prevScore.snp_trailing).constraint
            }
        }

        updateScores()
    }

    private func updateHighlight() {
        highlightedNameView.hidden = activePlayers.count == 0

        highlightedLeading?.uninstall()
        highlightedNameView.snp_makeConstraints { make in
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

    func playerTapped(sender: UIButton) {
        if let index = playerButtons.indexOf(sender) {
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
        savedPlayers = activePlayers.enumerate().map { ($0 + 1, $1.name) }
        playerTable.reloadData()
        overlay.hidden = false
        UIView.animateWithDuration(0.3) {
            self.overlay.alpha = 1
        }
    }

    func hideOverlay() {
        activePlayers = savedPlayers.sort({ $0.0 < $1.0 }).map { _, name in
            for player in activePlayers {
                if player.name == name {
                    return player
                }
            }
            return Player(name: name)
        }

        UIView.animateWithDuration(0.3, animations: {
            self.overlay.alpha = 0
        }, completion: { _ in
            self.overlay.hidden = true
        })
    }
}

extension MainScreen: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPlayers.count + 1
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row < allPlayers.count
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var newPlayers: [String] = []
            for (index, name) in allPlayers.enumerate() {
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

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        if indexPath.row == allPlayers.count {
            cell.textLabel?.textColor = .grayColor()
            cell.textLabel?.text = "New Player"
        }
        else {
            cell.textLabel?.textColor = .blackColor()
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if indexPath.row == allPlayers.count {
            let alert = UIAlertView(title: "New Player", message: "",
                delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
            alert.alertViewStyle = .PlainTextInput
            alert.show()

        }
        else {
            let name = allPlayers[indexPath.row]
            cell?.selected = false
            var found = false
            var players: [(Int, String)] = []
            var newIndex = 1
            for (_, player) in savedPlayers.sort({ $0.0 < $1.0 }) {
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

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1, let name = alertView.textFieldAtIndex(0)?.text
        where !name.characters.isEmpty && !allPlayers.contains(name)
        {
            allPlayers.append(name)
            playerTable.reloadData()
        }
    }
}
