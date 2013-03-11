class DigitalView < UIView
  LetterWidth = 24.0
  LetterHeight = 35.0

  DefaultText = '0'
  DefaultColor = :black
  DefaultPad = 3

  attr_accessor :text
  attr_accessor :pad
  attr_accessor :color

  # designated initializer
  def initWithText(text, color: color, pad: pad)
    self.initWithFrame([[0, 0], [0, 0]])

    self.backgroundColor = :gray

    self.text = text
    self.color = color
    self.pad = pad

    self.sizeToFit
    self
  end

  def intrinsicContentSize
    len = @text ? @text.length : 0
    len = @pad if @pad && @pad > len
    CGSize.new(LetterWidth * len, LetterHeight)
  end

  def initWithText(text, color: color)
    self.initWithText(text, color: color, pad: DefaultPad)
  end
  def initWithText(text)
    self.initWithText(text, color: DefaultColor, pad: DefaultPad)
  end
  def init
    self.initWithText(DefaultText, color: DefaultColor, pad: DefaultPad)
  end

  # Options
  #   text => text to output (default: '0')
  #   color => :black, :blue, or a UIColor instance (default: :black)
  #   pad => minimum number of letters to display (default: 3)
  def self.new(opts={})
    self.alloc.initWithText(opts[:text] || DefaultText,
                     color: opts[:color] || DefaultColor,
                       pad: opts[:pad] || DefaultPad)
  end

  ##|
  ##|  IMAGES
  ##|
  def top_image
    @@top_image ||= generate_image(:top)
  end
  def topleft_image
    @@topleft_image ||= generate_image(:topleft)
  end
  def topright_image
    @@topright_image ||= generate_image(:topright)
  end
  def middle_image
    @@middle_image ||= generate_image(:middle)
  end
  def bottomleft_image
    @@bottomleft_image ||= generate_image(:bottomleft)
  end
  def bottomright_image
    @@bottomright_image ||= generate_image(:bottomright)
  end
  def bottom_image
    @@bottom_image ||= generate_image(:bottom)
  end
  def colon
    @@colon_image ||= generate_image(:colon)
  end

  def generate_image(location, color=self.color)
    case color
    when :blue, :black, :gray
      UIImage.imageNamed("digital-#{color.to_s}-#{location.to_s}")
    else
      nil
    end
  end

  ##|
  ##|  SETTERS
  ##|
  def text=(text)
    @text = text.to_s
    setNeedsDisplay
    setNeedsUpdateConstraints
    @text
  end

  def pad=(pad)
    @pad = pad
    setNeedsDisplay
    setNeedsUpdateConstraints
    @pad
  end

  def color=(color)
    @color = color
    @top_image = nil
    @topleft_image = nil
    @topright_image = nil
    @middle_image = nil
    @bottomleft_image = nil
    @bottomright_image = nil
    @bottom_image = nil

    setNeedsDisplay

    @color
  end

  def backgroundColor=(val)
    @backgroundColor = val
    super UIColor.clearColor
    @backgroundColor
  end

  def backgroundColor
    @backgroundColor
  end

  ##|
  ##|  DRAWING
  ##|
  def letter_width
    if self.text.length * LetterWidth < self.frame.width
      LetterWidth
    else
      (self.frame.width / self.text.length).floor
    end
  end

  def letter_height
    (letter_width / LetterWidth * LetterHeight).floor
  end

  def letter_top
    (self.bounds.height - letter_height) / 2
  end

  def drawRect(frame)
    text = self.text
    length = [pad, text.length].max
    total_width = length * self.letter_width
    x = (self.bounds.width - total_width) / 2

    if pad and pad > text.length
      (pad - text.length).times do
        # just draws the background
        x += drawLetter(nil, at:x)
      end
    end

    # if text.length > pad
    #   text = text[(text.length - pad)..text.length]
    # end
    text.each_char do |letter|
      x += drawLetter(letter, at:x)
    end
  end

  def drawLetter(letter, at:x)
    draw_background = 'eight'

    case letter and letter.upcase
    when 'A'
      images = [top_image, topleft_image, topright_image, middle_image, bottomleft_image, bottomright_image]
    when 'B'
      images = [top_image, topleft_image, topright_image, middle_image, bottomleft_image, bottomright_image, bottom_image]
    when 'C'
      images = [top_image, topleft_image, bottomleft_image, bottom_image]
    when 'D'
      images = [top_image, topleft_image, topright_image, bottomleft_image, bottomright_image, bottom_image]
    when 'E'
      images = [top_image, topleft_image, middle_image, bottomleft_image, bottom_image]
    when 'F'
      images = [top_image, topleft_image, middle_image, bottomleft_image]
    when 'G'
      images = [top_image, topleft_image, bottomleft_image, bottomright_image, bottom_image]
    when 'H'
      images = [topleft_image, topright_image, middle_image, bottomleft_image, bottomright_image]
    when 'I'
      images = [topleft_image, bottomleft_image]
    when 'J'
      images = [top_image, topright_image, bottomleft_image, bottomright_image, bottom_image]
    when 'L'
      images = [topleft_image, bottomleft_image, bottom_image]
    when 'O'
      images = [top_image, topleft_image, topright_image, bottomleft_image, bottomright_image, bottom_image]
    when 'P'
      images = [top_image, topleft_image, topright_image, middle_image, bottomleft_image]
    when 'S'
      images = [top_image, topleft_image, middle_image, bottomright_image, bottom_image]
    when 'T'
      images = [middle_image, topright_image, bottomright_image]
    when 'U'
      images = [topleft_image, topright_image, bottomleft_image, bottomright_image, bottom_image]
    when 'Y'
      images = [topleft_image, topright_image, middle_image, bottomright_image]
    when 'Z'
      images = [top_image, topright_image, middle_image, bottomleft_image, bottom_image]
    when '-'
      images = [middle_image]
    when '_'
      images = [bottom_image]
    when '0'
      images = [top_image, topleft_image, topright_image, bottomleft_image, bottomright_image, bottom_image]
    when '1'
      images = [topright_image, bottomright_image]
    when '2'
      images = [top_image, topright_image, middle_image, bottomleft_image, bottom_image]
    when '3'
      images = [top_image, topright_image, middle_image, bottomright_image, bottom_image]
    when '4'
      images = [topleft_image, topright_image, middle_image, bottomright_image]
    when '5'
      images = [top_image, topleft_image, middle_image, bottomright_image, bottom_image]
    when '6'
      images = [top_image, topleft_image, middle_image, bottomleft_image, bottomright_image, bottom_image]
    when '7'
      images = [top_image, topright_image, bottomright_image]
    when '8'
      images = [top_image, topleft_image, topright_image, middle_image, bottomleft_image, bottomright_image, bottom_image]
    when '9'
      images = [top_image, topleft_image, topright_image, middle_image, bottomright_image, bottom_image]
    when ':'
      draw_background = false
      images = [colon]
    else
      images = []
    end

    if draw_background && backgroundColor
      bg_image = generate_image(draw_background, backgroundColor)
      if bg_image
        bg_image.drawInRect([[x, letter_top], [letter_width, letter_height]])
      else
        NSLog "Could not create background image with #{backgroundColor.inspect}"
      end
    end

    images.each {|image|
      if image
        image.drawInRect([[x, letter_top], [letter_width, letter_height]])
      else
        NSLog "Could not create image (?)"
      end
    }

    return self.letter_width
  end

  def sizeThatFits(size)
    return super unless text or pad

    length = pad and (!text or pad > text.length) ? pad : text.length
    [length * LetterWidth, LetterHeight]
  end

end
