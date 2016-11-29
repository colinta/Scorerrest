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

    var allPlayers: [String] = []
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
    var currentScore: Int? {
        get { return Int(currentScoreView.text) }
        set { currentScoreView.text = "\(newValue ?? 0)" }
    }
    var undoEnabled: Bool {
        get { return undoButton.isEnabled }
        set { undoButton.isEnabled = newValue }
    }
    weak var delegate: MainViewController?

    let namesView = UIScrollView()
    var scoreViews: [UILabel] = []
    var playerButtons: [UIButton] = []
    var scoreButtons: [UIButton] = []

    let highlightedNameView = UIView()
    var highlightedLeading: Constraint?
    let addPlayerButton = UIButton()
    var addPlayerLeading: Constraint?

    let scoreboardView = UIScrollView()
    var scoreboardTrailing: Constraint?
    let buttonContainer = UIView()
    let keypadContainer = UIView()
    var keypadVisible = false
    var buttonContainerWidth: Constraint?
    var buttonContainerBottom: Constraint?
    var keypadContainerBottom: Constraint?

    let currentScoreView = DigitalView()
    let restartButton = StyledButton(.gray, image: "restart")
    let clearButton = StyledButton(.gray, text: "C")
    let keypadButton = StyledButton(.gray, text: "123")
    let signButton = StyledButton(.red, text: "+/–")
    let okButton = StyledButton(.green, text: "OK")
    let memButton = StyledButton(.green, text: "M+")
    let undoButton = StyledButton(.green, image: "undo")

    let minusFiveButton = StyledButton(.minusFive, text: "–5")
    let minusOneButton = StyledButton(.minusOne, text: "–")
    let plusOneButton = StyledButton(.plusOne, text: "+")
    let plusFiveButton = StyledButton(.plusFive, text: "+5")

    let keypad1 = StyledButton(.blue, text: "1")
    let keypad2 = StyledButton(.blue, text: "2")
    let keypad3 = StyledButton(.blue, text: "3")
    let keypad4 = StyledButton(.blue, text: "4")
    let keypad5 = StyledButton(.blue, text: "5")
    let keypad6 = StyledButton(.blue, text: "6")
    let keypad7 = StyledButton(.blue, text: "7")
    let keypad8 = StyledButton(.blue, text: "8")
    let keypad9 = StyledButton(.blue, text: "9")
    let keypad0 = StyledButton(.blue, text: "0")
    let keypad00 = StyledButton(.blue, text: "00")
    let keypad000 = StyledButton(.blue, text: "000")

    let memFeed = UILabel()
    let memView = UIScrollView()
    var memViewWidth: Constraint?
    var memViewHeight: Constraint?

    let overlay = UIView()
    let overlayBg = UIView()

    let playerTable = UITableView()
    let playerTableHelper = PlayerTableHelper()

    let confirmButtons = UIView()
    let confirmButton = UIButton()
    let cancelButton = UIButton()
    var confirmHandler: BasicBlock?

    let scoresTable = UITableView()
    let scoresTableHelper = ScoresTableHelper()

    override func style() {
        let scoreboardColor = UIColor(patternImage: UIImage(named: "notepad")!)
        scoreboardView.backgroundColor = scoreboardColor

        addPlayerButton.setTitle("+", for: .normal)
        addPlayerButton.setTitleColor(.white, for: .normal)
        addPlayerButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        addPlayerButton.backgroundColor = UIColor(hex: 0x70B304)
        addPlayerButton.titleEdgeInsets.bottom = 4
        addPlayerButton.layer.cornerRadius = 5

        undoButton.isEnabled = false

        confirmButton.setTitle("OK", for: .normal)
        confirmButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        confirmButton.setTitleColor(.black, for: .normal)
        confirmButton.backgroundColor = .white
        confirmButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = .black
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)

        highlightedNameView.backgroundColor = .yellow
        highlightedNameView.isHidden = true

        minusFiveButton.titleEdgeInsets.right = Size.buttonOverlap
        plusFiveButton.titleEdgeInsets.right = Size.buttonOverlap
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
        scoresTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func bindActions() {
        restartButton.addTarget(self, action: #selector(restartTapped), for: .touchUpInside)
        undoButton.addTarget(self, action: #selector(undoTapped), for: .touchUpInside)
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
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        scoreboardView.delegate = self
        namesView.delegate = self

        playerTableHelper.delegate = self
        playerTableHelper.table = playerTable
        playerTable.dataSource = playerTableHelper
        playerTable.delegate = playerTableHelper

        scoresTableHelper.delegate = self
        scoresTableHelper.table = scoresTable
        scoresTable.dataSource = scoresTableHelper
        scoresTable.delegate = scoresTableHelper

        keypad1.addTarget(self, action: #selector(keypadNumberTapped), for: .touchUpInside)
        keypad2.addTarget(self, action: #selector(keypadNumberTapped), for: .touchUpInside)
        keypad3.addTarget(self, action: #selector(keypadNumberTapped), for: .touchUpInside)
        keypad4.addTarget(self, action: #selector(keypadNumberTapped), for: .touchUpInside)
        keypad5.addTarget(self, action: #selector(keypadNumberTapped), for: .touchUpInside)
        keypad6.addTarget(self, action: #selector(keypadNumberTapped), for: .touchUpInside)
        keypad7.addTarget(self, action: #selector(keypadNumberTapped), for: .touchUpInside)
        keypad8.addTarget(self, action: #selector(keypadNumberTapped), for: .touchUpInside)
        keypad9.addTarget(self, action: #selector(keypadNumberTapped), for: .touchUpInside)
        keypad0.addTarget(self, action: #selector(keypadNumberTapped), for: .touchUpInside)
        keypad00.addTarget(self, action: #selector(keypadNumberTapped), for: .touchUpInside)
        keypad000.addTarget(self, action: #selector(keypadNumberTapped(_:)), for: .touchUpInside)

        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(hideOverlay))
        overlayBg.addGestureRecognizer(gesture)
    }

    override func arrange() {
        addSubview(namesView)
        addSubview(scoreboardView)
        addSubview(buttonContainer)
        addSubview(keypadContainer)
        addSubview(overlay)

        namesView.addSubview(highlightedNameView)
        namesView.addSubview(addPlayerButton)

        buttonContainer.addSubview(currentScoreView)
        buttonContainer.addSubview(restartButton)
        buttonContainer.addSubview(clearButton)
        buttonContainer.addSubview(keypadButton)
        buttonContainer.addSubview(okButton)
        buttonContainer.addSubview(memButton)
        buttonContainer.addSubview(undoButton)
        buttonContainer.addSubview(minusFiveButton)
        buttonContainer.addSubview(plusFiveButton)
        buttonContainer.addSubview(minusOneButton)
        buttonContainer.addSubview(plusOneButton)
        buttonContainer.addSubview(memView)

        keypadContainer.addSubview(keypad1)
        keypadContainer.addSubview(keypad2)
        keypadContainer.addSubview(keypad3)
        keypadContainer.addSubview(keypad4)
        keypadContainer.addSubview(keypad5)
        keypadContainer.addSubview(keypad6)
        keypadContainer.addSubview(keypad7)
        keypadContainer.addSubview(keypad8)
        keypadContainer.addSubview(keypad9)
        keypadContainer.addSubview(keypad0)
        keypadContainer.addSubview(keypad00)
        keypadContainer.addSubview(keypad000)
        keypadContainer.addSubview(signButton)

        memView.addSubview(memFeed)

        overlay.addSubview(overlayBg)
        overlay.addSubview(playerTable)
        overlay.addSubview(scoresTable)
        overlay.addSubview(confirmButtons)
        confirmButtons.addSubview(confirmButton)
        confirmButtons.addSubview(cancelButton)

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
        }

        buttonContainer.snp.makeConstraints { make in
            make.width.equalTo(self).priority(Priority.Medium)
            make.width.lessThanOrEqualTo(Size.buttonContainerMaxWidth).priority(Priority.High)
            make.centerX.equalTo(self)
            buttonContainerBottom = make.bottom.equalTo(self).constraint
            make.top.lessThanOrEqualTo(currentScoreView.snp.top)
            make.top.lessThanOrEqualTo(undoButton.snp.top)
            make.top.lessThanOrEqualTo(restartButton.snp.top)
        }
        let buttonContainerWidthAnchor = UIView()
        buttonContainer.addSubview(buttonContainerWidthAnchor)
        buttonContainerWidthAnchor.snp.makeConstraints { make in
            buttonContainerWidth = make.width.equalTo(frame.size.width).priority(Priority.Required).constraint
            make.leading.trailing.equalTo(buttonContainer)
        }

        keypadContainer.snp.makeConstraints { make in
            make.leading.trailing.width.equalTo(buttonContainer)
            make.top.equalTo(buttonContainer.snp.bottom)
            keypadContainerBottom = make.bottom.equalTo(self).constraint
        }
        keypadContainerBottom?.deactivate()

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
        restartButton.snp.makeConstraints { make in
            make.leading.equalTo(buttonContainer).offset(Size.margin)
            make.bottom.equalTo(clearButton.snp.top).offset(-Size.margin)
        }
        okButton.snp.makeConstraints { make in
            make.trailing.equalTo(buttonContainer).offset(-Size.margin)
            make.bottom.equalTo(buttonContainer).offset(-Size.bottomMargin)
        }
        memButton.snp.makeConstraints { make in
            make.trailing.equalTo(buttonContainer).offset(-Size.margin)
            make.bottom.equalTo(okButton.snp.top).offset(-Size.margin)
        }
        undoButton.snp.makeConstraints { make in
            make.trailing.equalTo(buttonContainer).offset(-Size.margin)
            make.bottom.equalTo(memButton.snp.top).offset(-Size.margin)
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

        signButton.snp.makeConstraints { make in
            make.leading.equalTo(keypadContainer).offset(Size.margin)
            make.bottom.equalTo(keypad0)
        }

        keypad7.snp.makeConstraints { make in
            make.top.equalTo(keypad8)
            make.trailing.equalTo(keypad8.snp.leading).offset(-Size.margin)
        }
        keypad8.snp.makeConstraints { make in
            make.top.equalTo(keypadContainer).offset(Size.margin)
            make.centerX.equalTo(keypadContainer)
        }
        keypad9.snp.makeConstraints { make in
            make.top.equalTo(keypad8)
            make.leading.equalTo(keypad8.snp.trailing).offset(Size.margin)
        }

        keypad4.snp.makeConstraints { make in
            make.top.equalTo(keypad5)
            make.trailing.equalTo(keypad5.snp.leading).offset(-Size.margin)
        }
        keypad5.snp.makeConstraints { make in
            make.top.equalTo(keypad8.snp.bottom).offset(Size.margin)
            make.centerX.equalTo(keypadContainer)
        }
        keypad6.snp.makeConstraints { make in
            make.top.equalTo(keypad5)
            make.leading.equalTo(keypad5.snp.trailing).offset(Size.margin)
        }

        keypad1.snp.makeConstraints { make in
            make.top.equalTo(keypad2)
            make.trailing.equalTo(keypad2.snp.leading).offset(-Size.margin)
        }
        keypad2.snp.makeConstraints { make in
            make.top.equalTo(keypad5.snp.bottom).offset(Size.margin)
            make.centerX.equalTo(keypadContainer)
        }
        keypad3.snp.makeConstraints { make in
            make.top.equalTo(keypad2)
            make.leading.equalTo(keypad2.snp.trailing).offset(Size.margin)
        }

        keypad0.snp.makeConstraints { make in
            make.top.equalTo(keypad00)
            make.trailing.equalTo(keypad00.snp.leading).offset(-Size.margin)
        }
        keypad00.snp.makeConstraints { make in
            make.top.equalTo(keypad2.snp.bottom).offset(Size.margin)
            make.centerX.equalTo(keypadContainer)
            make.bottom.equalTo(keypadContainer).offset(-Size.margin)
        }
        keypad000.snp.makeConstraints { make in
            make.top.equalTo(keypad00)
            make.leading.equalTo(keypad00.snp.trailing).offset(Size.margin)
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
        scoresTable.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(overlay).inset(Size.tableMargins)
            make.bottom.equalTo(overlay).offset(-Size.tableMargins.bottom).priority(Priority.Medium)
            make.bottom.equalTo(keyboardAnchor.snp.top).offset(-Size.tableMargins.bottom).priority(Priority.Required)
        }
        confirmButtons.snp.makeConstraints { make in
            make.center.equalTo(overlay)
        }
        confirmButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(confirmButtons)
        }
        cancelButton.snp.makeConstraints { make in
            make.leading.equalTo(confirmButton.snp.trailing).offset(Size.margin)
            make.trailing.top.bottom.equalTo(confirmButtons)
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
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject,
        ]
        for (index, player) in activePlayers.enumerated() {
            let playerView = playerButtons[index]
            let title: String
            if player.score == 0 {
                title = player.name
            }
            else {
                title = "\(player.name)\n\(player.score.localized)"
            }
            playerView.setTitle(title, for: .normal)
            let scoreboardLabel = scoreViews[index]

            let scoreText = NSMutableAttributedString()
            var first = true
            var total = 0
            for score in player.scores {
                total += score
                if first {
                    scoreText.append(NSAttributedString(string: "\(score.localized)\n", attributes: normal))
                }
                else {
                    let scoreString: String = (score >= 0 ? "+ \(score.localized)" : "- \((-score).localized)")
                    scoreText.append(NSAttributedString(string: scoreString, attributes: underlined))
                    scoreText.append(NSAttributedString(string: "\n\(total.localized)\n", attributes: normal))
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
    func updateNameViews() {
        for view in playerButtons {
            view.removeFromSuperview()
        }
        for view in scoreViews {
            view.removeFromSuperview()
        }

        var prevView: UIView?
        var prevScore: UIView?
        playerButtons = []
        scoreButtons = []
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
                make.width.equalTo(Size.highlightedSize.width - 2 * Size.margin)
            }

            let adjustScoreButton = UIButton()
            scoreButtons.append(adjustScoreButton)
            scoreboardView.addSubview(adjustScoreButton)
            adjustScoreButton.snp.makeConstraints { make in
                make.top.bottom.equalTo(scoreboardView)
                make.leading.trailing.equalTo(score)
            }
            adjustScoreButton.addTarget(self, action: #selector(adjustScoresTapped(_:)), for: .touchUpInside)

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
        updateHighlight()
    }

    func updateHighlight() {
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
        namesView.scrollRectToVisible(highlightedNameView.frame, animated: true)
    }
}

// MARK: Actions
extension MainScreen {
    func restartTapped() {
        showConfirm("Restart game?") {
            self.delegate?.restartTapped()
        }
    }
    func undoTapped() {
        delegate?.undoTapped()
    }
    func clearTapped() {
        delegate?.clearTapped()
    }

    func keypadTapped() {
        keypadVisible = !keypadVisible
        if keypadVisible {
            buttonContainerBottom?.deactivate()
            keypadContainerBottom?.activate()
        }
        else {
            keypadContainerBottom?.deactivate()
            buttonContainerBottom?.activate()
        }
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    func keypadNumberTapped(_ sender: UIButton) {
        switch sender {
        case keypad1: delegate?.concat(number: "1")
        case keypad2: delegate?.concat(number: "2")
        case keypad3: delegate?.concat(number: "3")
        case keypad4: delegate?.concat(number: "4")
        case keypad5: delegate?.concat(number: "5")
        case keypad6: delegate?.concat(number: "6")
        case keypad7: delegate?.concat(number: "7")
        case keypad8: delegate?.concat(number: "8")
        case keypad9: delegate?.concat(number: "9")
        case keypad0: delegate?.concat(number: "0")
        case keypad00: delegate?.concat(number: "00")
        case keypad000: delegate?.concat(number: "000")
        default: break
        }
    }

    func signTapped() {
        delegate?.signTapped()
    }

    func adjustScoresTapped(_ sender: UIButton) {
        if let index = scoreButtons.index(of: sender) {
            if index == currentPlayer {
                showScores()
            }
            else {
                currentPlayer = index
            }
        }
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

    func confirmTapped() {
        confirmHandler?()
        confirmHandler = nil
        hideOverlay()
    }

    func cancelTapped() {
        confirmHandler = nil
        hideOverlay()
    }
}

extension MainScreen {
    private func showOverlay() {
        overlay.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.overlay.alpha = 1
        }
    }

    func showConfirm(_ message: String, handler: @escaping BasicBlock) {
        confirmButton.setTitle(message, for: .normal)
        showOverlay()
        confirmHandler = handler
        playerTable.isHidden = true
        scoresTable.isHidden = true
        confirmButtons.isHidden = false
    }

    func showScores() {
        showOverlay()
        let scores: [Int] = activePlayers[currentPlayer].scores
        scoresTableHelper.scores = scores
        scoresTable.reloadData()

        playerTable.isHidden = true
        scoresTable.isHidden = false
        confirmButtons.isHidden = true
    }

    func showPlayers() {
        showOverlay()
        var added = false
        for player in activePlayers {
            if !allPlayers.contains(player.name) {
                allPlayers.append(player.name)
                added = true
            }
        }
        if added {
            delegate?.allPlayersUpdated(allPlayers)
        }

        playerTableHelper.allPlayers = allPlayers
        playerTableHelper.activePlayers = activePlayers
        playerTable.reloadData()

        playerTable.isHidden = false
        scoresTable.isHidden = true
        confirmButtons.isHidden = true
    }

    func hideOverlay() {
        if !playerTable.isHidden {
            let prevPlayers = activePlayers.map { $0.name }
            let currentPlayers: [Player] = playerTableHelper.savedPlayers.sorted(by: { $0.0 < $1.0 }).map { _, name in
                for player in activePlayers {
                    if player.name == name {
                        return player
                    }
                }
                return Player(name: name)
            }
            if prevPlayers != currentPlayers.map { $0.name } {
                delegate?.activePlayersWillUpdate()
            }
            activePlayers = currentPlayers
        }
        else if !scoresTable.isHidden {
            delegate?.activePlayersWillUpdate()
            activePlayers[currentPlayer].scores = scoresTableHelper.scores
            updateNameViews()
            delegate?.save()
        }
        confirmHandler = nil

        UIView.animate(withDuration: 0.3, animations: {
            self.overlay.alpha = 0
        }, completion: { _ in
            self.overlay.isHidden = true
        })
    }
}

extension MainScreen {
    func allPlayersUpdated(allPlayers: [String]) {
        self.allPlayers = allPlayers
        delegate?.allPlayersUpdated(allPlayers)
    }
}

extension MainScreen {
    func scoresUpdated(scores: [Int]) {
    }
}
