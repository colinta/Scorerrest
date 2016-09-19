////
///  DigitalView.swift
//

class DigitalView: UIView {
    struct Size {
        static let letterSize = CGSize(width: 24, height: 35)
        static let minTextLength = 3
    }
    enum Color: String {
        case black
        case blue
    }

    var text: String = "0" { didSet {
        guard text != oldValue else { return }
        setNeedsDisplay()
        invalidateIntrinsicContentSize()
    } }
    var minTextLength: Int = Size.minTextLength { didSet {
        guard minTextLength != oldValue else { return }
        setNeedsDisplay()
        invalidateIntrinsicContentSize()
    } }
    var color: Color = .black { didSet {
        guard color != oldValue else { return }
        generateAllImages()
        setNeedsDisplay()
        invalidateIntrinsicContentSize()
    } }

    //|
    //|  IMAGES
    //|
    var topImage: UIImage!
    var topLeftImage: UIImage!
    var topRightImage: UIImage!
    var middleImage: UIImage!
    var bottomLeftImage: UIImage!
    var bottomRightImage: UIImage!
    var bottomImage: UIImage!
    var colon: UIImage!
    var background: UIImage!

    fileprivate func generateAllImages() {
        topImage = generateImage("top")
        topLeftImage = generateImage("topLeft")
        topRightImage = generateImage("topRight")
        middleImage = generateImage("middle")
        bottomLeftImage = generateImage("bottomLeft")
        bottomRightImage = generateImage("bottomRight")
        bottomImage = generateImage("bottom")
        colon = generateImage("colon")
        background = generateImage("eight", color: "gray")
    }

    fileprivate func generateImage(_ location: String, color optColor: String? = nil) -> UIImage? {
        let color = optColor ?? self.color.rawValue
        return UIImage(named: "digital-\(color)-\(location)")
    }

    override required init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        generateAllImages()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let len = CGFloat(max(minTextLength, text.characters.count))
        return CGSize(width: Size.letterSize.width * len, height: Size.letterSize.height)
    }

    //|
    //|  DRAWING
    //|
    func drawLetterWidth() -> CGFloat {
        if CGFloat(text.characters.count) * Size.letterSize.width < frame.width {
            return Size.letterSize.width
        }
        else {
            return floor(frame.width / CGFloat(text.characters.count))
        }
    }

    func drawLetterHeight() -> CGFloat {
        return floor(drawLetterWidth() / Size.letterSize.width * Size.letterSize.height)
    }

    func drawLetterTop() -> CGFloat {
        return (frame.height - drawLetterHeight()) / 2
    }

    override func draw(_ frame: CGRect) {
        let length = max(minTextLength, text.characters.count)
        let totalWidth = CGFloat(length) * self.drawLetterWidth()
        var x = (frame.width - totalWidth) / 2

        if minTextLength > text.characters.count {
            times(minTextLength - text.characters.count) {
                // just draws the background
                drawBackground(at: x)
                x += drawLetterWidth()
            }
        }

        for letter in text.characters.map({ String($0) }) {
            drawLetter(letter, at: x)
            x += drawLetterWidth()
        }
    }

    func drawBackground(at x: CGFloat) {
        background.draw(in: CGRect(
            x: x,
            y: drawLetterTop(),
            width: drawLetterWidth(),
            height: drawLetterHeight()
            ))
    }

    func drawLetter(_ letter: String, at x: CGFloat) {
        var shouldDrawBackground = true
        let images: [UIImage]
        switch letter {
        case "a":
            images = [topImage]
        case "b":
            images = [topRightImage]
        case "c":
            images = [bottomRightImage]
        case "d":
            images = [bottomImage]
        case "e":
            images = [bottomLeftImage]
        case "f":
            images = [topLeftImage]
        case "g":
            images = [middleImage]
        case "-":
            images = [middleImage]
        case "_":
            images = [bottomImage]
        case "0":
            images = [topImage, topLeftImage, topRightImage, bottomLeftImage, bottomRightImage, bottomImage]
        case "1":
            images = [topRightImage, bottomRightImage]
        case "2":
            images = [topImage, topRightImage, middleImage, bottomLeftImage, bottomImage]
        case "3":
            images = [topImage, topRightImage, middleImage, bottomRightImage, bottomImage]
        case "4":
            images = [topLeftImage, topRightImage, middleImage, bottomRightImage]
        case "5":
            images = [topImage, topLeftImage, middleImage, bottomRightImage, bottomImage]
        case "6":
            images = [topImage, topLeftImage, middleImage, bottomLeftImage, bottomRightImage, bottomImage]
        case "7":
            images = [topImage, topRightImage, bottomRightImage]
        case "8":
            images = [topImage, topLeftImage, topRightImage, middleImage, bottomLeftImage, bottomRightImage, bottomImage]
        case "9":
            images = [topImage, topLeftImage, topRightImage, middleImage, bottomRightImage, bottomImage]
        case ":":
            shouldDrawBackground = false
            images = [colon]
        default:
            images = []
        }

        if shouldDrawBackground {
            drawBackground(at: x)
        }

        let rect = CGRect(
            x: x,
            y: drawLetterTop(),
            width: drawLetterWidth(),
            height: drawLetterHeight()
            )
        for image in images {
            image.draw(in: rect)
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let length = max(minTextLength, text.characters.count)
        return CGSize(width: CGFloat(length) * Size.letterSize.width, height: Size.letterSize.height)
    }

}
