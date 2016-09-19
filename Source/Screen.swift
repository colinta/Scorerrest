////
///  Screen.swift
//

import SnapKit


class Screen: UIView {
    let keyboardAnchor = UIView()
    fileprivate var keyboardConstraint: Constraint!
    fileprivate var keyboardWillShowObserver: NotificationObserver?
    fileprivate var keyboardWillHideObserver: NotificationObserver?

    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(keyboardAnchor)
        backgroundColor = .white

        screenInit()
        style()
        bindActions()
        setText()
        arrange()

        keyboardAnchor.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self)
            keyboardConstraint = make.top.equalTo(self.snp.bottom).constraint
        }

        // for controllers that use "container" views, they need to be set to the correct dimensions,
        // otherwise there'll be constraint violations.
        layoutIfNeeded()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        teardownKeyboardObservers()
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        if newWindow != nil && window == nil {
            setupKeyboardObservers()
        }
        else if newWindow == nil && window != nil {
            teardownKeyboardObservers()
        }
    }

    fileprivate func setupKeyboardObservers() {
        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: keyboardWillChange)
        keyboardWillHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillHide, block: keyboardWillChange)
    }

    fileprivate func teardownKeyboardObservers() {
        keyboardWillShowObserver?.removeObserver()
        keyboardWillHideObserver?.removeObserver()
        keyboardWillShowObserver = nil
        keyboardWillHideObserver = nil
    }

    func keyboardWillChange(_ keyboard: Keyboard) {
        let bottomInset = keyboard.keyboardBottomInset(inView: self)
        animate(duration: keyboard.duration, options: keyboard.options, completion: { _ in self.keyboardDidAnimate() }) {
            self.keyboardConstraint.update(offset: -bottomInset)
            self.keyboardIsAnimating(keyboard)
            self.layoutIfNeeded()
        }
    }

    func keyboardIsAnimating(_ keyboard: Keyboard) {}
    func keyboardDidAnimate() {}

    func screenInit() {}
    func style() {}
    func bindActions() {}
    func setText() {}
    func arrange() {}
}
