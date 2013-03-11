class TimerGame < Game
  include TimerGameConstants

  attr_accessor :game_length
  attr_accessor :randomize
  attr_accessor :auto_repeat
  attr_accessor :display
  attr_accessor :ticking
  attr_accessor :buzzer

  def initialize
    super
    self.game_length = [0, 1, 0]
    self.randomize = nil
    self.auto_repeat = false
    self.display = nil  # or DisplayX constant
    self.ticking = nil  # or TickingX constant
    self.buzzer = true
    # don't save timers
    self.save = false
  end

  ##|
  ##|  NS-ENCODING
  ##|
  def encodeWithCoder(coder)
    super
    coder.encodeObject(self.game_length, forKey:'game_length')
    coder.encodeObject(self.randomize, forKey:'randomize')
    coder.encodeBool(self.auto_repeat, forKey:'auto_repeat')
    coder.encodeObject(self.display, forKey:'display')
    coder.encodeObject(self.ticking, forKey:'ticking')
    coder.encodeBool(self.buzzer, forKey:'buzzer')
  end

  def initWithCoder(coder)
    super
    self.game_length = coder.decodeObjectForKey('game_length')
    self.randomize = coder.decodeObjectForKey('randomize')
    self.auto_repeat = coder.decodeBoolForKey('auto_repeat')
    self.display = coder.decodeObjectForKey('display')
    self.ticking = coder.decodeObjectForKey('ticking')
    self.buzzer = coder.decodeBoolForKey('buzzer')
    return self
  end

  ##|
  ##|  DEBUG
  ##|
  def inspect append=nil
    super "game_length: #{game_length.inspect}#{append ? ', ' + append : ''}"
  end

end
