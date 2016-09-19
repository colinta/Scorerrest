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
            case .medium: return CGSize(width: 45, height: 35)
            case .wide: return CGSize(width: 55, height: 35)
            case .large: return CGSize(width: 55, height: 40)
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
            corners: UIRectCorner = [.TopLeft, .TopRight, .BottomLeft, .BottomRight]
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

    private var internalBackgroundColor: UIColor? {
        didSet {
            if oldValue != internalBackgroundColor { setNeedsDisplay() }
        }
    }

    override var highlighted: Bool {
        didSet { updateStyle() }
    }

    private func updateStyle() {
        if highlighted {
            internalBackgroundColor = style.highlightedBackgroundColor ?? style.backgroundColor
        }
        else {
            internalBackgroundColor = style.backgroundColor
        }

        titleLabel?.font = style.font
        setTitleColor(style.highlightedTitleColor, forState: .Highlighted)
        setTitleColor(style.titleColor, forState: .Normal)
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
        self.setTitle(text, forState: .Normal)
        updateStyle()
    }

    override func intrinsicContentSize() -> CGSize {
        return style.cgsize
    }

    private func sharedSetup() {
        titleLabel?.numberOfLines = 1
        updateStyle()
    }

    override func drawRect(frame: CGRect) {
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
        backgroundColor: .blackColor(), highlightedBackgroundColor: .darkGrayColor(),
        titleColor: .whiteColor()
        )
    static let gray = StyledButton.Style(
        backgroundColor: UIColor(hex: 0x8E8B8F), highlightedBackgroundColor: UIColor(hex: 0xA6A6A6),
        titleColor: .whiteColor()
        )
    static let green = StyledButton.Style(
        backgroundColor: UIColor(hex: 0x70B304), highlightedBackgroundColor: UIColor(hex: 0x7EE10A),
        titleColor: .whiteColor()
    )

    static let red = StyledButton.Style(
        backgroundColor: UIColor(hex: 0xC82A04), highlightedBackgroundColor: UIColor(hex: 0xFC1D0A),
        titleColor: .whiteColor()
        )
    static let minusOne = StyledButton.Style(
        backgroundColor: UIColor(hex: 0xC82A04), highlightedBackgroundColor: UIColor(hex: 0xFC1D0A),
        titleColor: .whiteColor(),
        size: .large, corners: [.TopLeft, .BottomLeft]
        )
    static let blue = StyledButton.Style(
        backgroundColor: UIColor(hex: 0x2895F3), highlightedBackgroundColor: UIColor(hex: 0x4AA0FF),
        titleColor: .whiteColor()
    )
    static let plusOne = StyledButton.Style(
        backgroundColor: UIColor(hex: 0x2895F3), highlightedBackgroundColor: UIColor(hex: 0x4AA0FF),
        titleColor: .whiteColor(),
        size: .large, corners: [.TopRight, .BottomRight]
        )

    static let minusFive = StyledButton.Style(
        backgroundColor: UIColor(hex: 0xA12403), highlightedBackgroundColor: UIColor(hex: 0xBF1B08),
        titleColor: .whiteColor(),
        size: .wide
        )
    static let plusFive = StyledButton.Style(
        backgroundColor: UIColor(hex: 0x227ECA), highlightedBackgroundColor: UIColor(hex: 0x2382EE),
        titleColor: .whiteColor(),
        size: .wide
        )
}
