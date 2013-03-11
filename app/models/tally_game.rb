class TallyGame < Game
  attr_accessor :players
  attr_accessor :scores

  attr_accessor :current_score
  attr_accessor :this_score
  attr_accessor :this_player
  attr_accessor :is_locked
  attr_accessor :undo_stack

  def initialize
    super
    self.current_score = 0
    self.this_score = 0
    self.this_player = 0
    self.is_locked = false
    self.undo_stack = []
  end

  def addScore(score, toPlayerAt: index)
    self.addScore(score, toPlayer: self.players[index])
  end

  def addScore(score, toPlayer: player)
    self.scores[player['name']] << score
    self
  end

  def scoresFor(player)
    self.scores[player['name']]
  end

  def scores
    @scores ||= Hash.new do |hash,key|
      hash[key] = []
    end
  end

  def scores= values
    values.each_pair do |key, value|
      self.scores[key] = value
    end
    values
  end

  ##|
  ##|  NS-ENCODING
  ##|
  def encodeWithCoder(coder)
    super
    coder.encodeObject(self.players.map{|p| p['name']}, forKey:"player-names")
    coder.encodeObject(self.scores, forKey:"scores")
    coder.encodeObject(self.undo_stack, forKey:"undo_stack")
    coder.encodeInt(self.current_score, forKey:"current_score")
    coder.encodeInt(self.this_score, forKey:"this_score")
    coder.encodeInt(self.this_player, forKey:"this_player")
    coder.encodeBool(self.is_locked, forKey:"is_locked")
  end

  def initWithCoder(coder)
    super
    self.players = coder.decodeObjectForKey("player-names").map{|name| {'name' => name}}
    self.scores = coder.decodeObjectForKey("scores")
    self.undo_stack = coder.decodeObjectForKey("undo_stack")
    self.current_score = coder.decodeIntForKey("current_score")
    self.this_score = coder.decodeIntForKey("this_score")
    self.this_player = coder.decodeIntForKey("this_player")
    self.is_locked = coder.decodeBoolForKey("is_locked")
    return self
  end

  ##|
  ##|  DEBUG
  ##|
  def inspect append=nil
    super "players: #{self.players.inspect}, scores: #{self.scores.inspect}#{append ? ', ' + append : ''}"
  end

end
