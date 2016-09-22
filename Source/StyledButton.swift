////
///  StyledButton.swift
//

final class StyledButton: UIButton {
    enum Size {
        case medium
        case wide
        case large
    }

    struct Style {
        let highlightedBackgroundColor: UIColor?
        let backgroundColor: UIColor?

        let highlightedTitleColor: UIColor?
        let titleColor: UIColor?

        let corners: UIRectCorner
        let cornerRadius: CGFloat?

        let fontSize: CGFloat
        var font: UIFont {
            return UIFont(name: "HelveticaNeue-Light", size: 20)!
        }

        let size: Size
        var cgsize: CGSize {
            switch size {
            case .medium: return CGSize(width: 45, height: 40)
            case .wide: return CGSize(width: 55, height: 40)
            case .large: return CGSize(width: 55, height: 45)
            }
        }

        init(
            backgroundColor: UIColor?,
            highlightedBackgroundColor: UIColor?,

            titleColor: UIColor? = nil,
            highlightedTitleColor: UIColor? = nil,

            fontSize: CGFloat = 20,
            cornerRadius: CGFloat? = 5,
            size: Size = .medium,
            corners: UIRectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
        ) {
            self.highlightedBackgroundColor = highlightedBackgroundColor
            self.backgroundColor = backgroundColor

            self.highlightedTitleColor = highlightedTitleColor
            self.titleColor = titleColor

            self.fontSize = fontSize
            self.corners = corners
            self.cornerRadius = cornerRadius
            self.size = size
        }
    }

    var style: Style = .Default {
        didSet { updateStyle() }
    }

    fileprivate var internalBackgroundColor: UIColor? {
        didSet {
            if oldValue != internalBackgroundColor { setNeedsDisplay() }
        }
    }

    override var isHighlighted: Bool {
        didSet { updateStyle() }
    }

    fileprivate func updateStyle() {
        if isHighlighted {
            internalBackgroundColor = style.highlightedBackgroundColor ?? style.backgroundColor
        }
        else {
            internalBackgroundColor = style.backgroundColor
        }

        titleLabel?.font = style.font
        setTitleColor(style.highlightedTitleColor, for: .highlighted)
        setTitleColor(style.titleColor, for: .normal)
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        sharedSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedSetup()
    }

    convenience init(_ style: Style, text: String = "") {
        self.init()
        self.style = style
        self.setTitle(text, for: .normal)
        updateStyle()
    }

    convenience init(_ style: Style, image: String) {
        self.init()
        self.style = style
        self.setImage(UIImage(named: image), for: .normal)
        self.imageView?.contentMode = .center
        updateStyle()
    }

    override var intrinsicContentSize: CGSize {
        return style.cgsize
    }

    fileprivate func sharedSetup() {
        titleLabel?.numberOfLines = 1
        updateStyle()
    }

    override func draw(_ frame: CGRect) {
        guard let internalBackgroundColor = internalBackgroundColor else { return }

        let pathRadius: CGFloat
        if let cornerRadius = style.cornerRadius {
            pathRadius = cornerRadius
        }
        else {
            pathRadius = min(frame.height, frame.width) / 2
        }

        let path: UIBezierPath
        if pathRadius > 0 {
            path = UIBezierPath(
                roundedRect: self.bounds,
                byRoundingCorners: style.corners,
                cornerRadii: CGSize(width: pathRadius, height: pathRadius)
            )
        }
        else {
            path = UIBezierPath(rect: self.bounds)
        }

        internalBackgroundColor.setFill()
        path.fill()
    }
}

extension StyledButton.Style {
    static let Default = StyledButton.Style(
        backgroundColor: .black, highlightedBackgroundColor: .darkGray,
        titleColor: .white
        )
    static let gray = StyledButton.Style(
        backgroundColor: UIColor(hex: 0x8E8B8F), highlightedBackgroundColor: UIColor(hex: 0xA6A6A6),
        titleColor: .white
        )
    static let green = StyledButton.Style(
        backgroundColor: UIColor(hex: 0x70B304), highlightedBackgroundColor: UIColor(hex: 0x7EE10A),
        titleColor: .white
    )

    static let red = StyledButton.Style(
        backgroundColor: UIColor(hex: 0xC82A04), highlightedBackgroundColor: UIColor(hex: 0xFC1D0A),
        titleColor: .white
        )
    static let minusOne = StyledButton.Style(
        backgroundColor: UIColor(hex: 0xC82A04), highlightedBackgroundColor: UIColor(hex: 0xFC1D0A),
        titleColor: .white,
        size: .large, corners: [.topLeft, .bottomLeft]
        )
    static let blue = StyledButton.Style(
        backgroundColor: UIColor(hex: 0x2895F3), highlightedBackgroundColor: UIColor(hex: 0x4AA0FF),
        titleColor: .white
    )
    static let plusOne = StyledButton.Style(
        backgroundColor: UIColor(hex: 0x2895F3), highlightedBackgroundColor: UIColor(hex: 0x4AA0FF),
        titleColor: .white,
        size: .large, corners: [.topRight, .bottomRight]
        )

    static let minusFive = StyledButton.Style(
        backgroundColor: UIColor(hex: 0xA12403), highlightedBackgroundColor: UIColor(hex: 0xBF1B08),
        titleColor: .white,
        size: .wide
        )
    static let plusFive = StyledButton.Style(
        backgroundColor: UIColor(hex: 0x227ECA), highlightedBackgroundColor: UIColor(hex: 0x2382EE),
        titleColor: .white,
        size: .wide
        )
}
