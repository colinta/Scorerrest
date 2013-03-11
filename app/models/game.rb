class Game
  attr_accessor :save

  @controller_for_game = {}

  class << self

    def plist
      'games.plist'.document
    end

    def persist
      NSKeyedArchiver.archiveRootObject(self.games.select{|game|game.save}, toFile:self.plist)
    end

    def games
      @games ||= load_games
    end

    def <<(game)
      self.games << game
      GamesChangedNotification.post_notification
    end

    def delete_game_at(index)
      self.games.delete_at(index)
      GamesChangedNotification.post_notification
    end

    def controller_for_game(game)
      return @controller_for_game[game] if @controller_for_game[game]

      case game
      when TallyGame
        klass = TallyGameController
      when TimerGame
        klass = TimerGameController
      else
        raise "Unknown game #{game} (#{game.class})"
      end
      controller = klass.alloc.initWithGame(game)
      @controller_for_game[game] = controller

      return controller
    end

    private
    def load_games
      if plist.exists?
        games = NSKeyedUnarchiver.unarchiveObjectWithFile(self.plist) || []
      else
        games = []
      end

      games
    end
  end

  attr_accessor :name
  attr_accessor :subtitle

  def initialize
    self.name = ''
    self.subtitle = ''
    self.save = true
  end

  ##|
  ##|  NS-ENCODING
  ##|
  def encodeWithCoder(coder)
    coder.encodeObject(self.name, forKey:'name')
    coder.encodeObject(self.subtitle, forKey:'subtitle')
  end

  def initWithCoder(coder)
    self.name = coder.decodeObjectForKey('name')
    self.subtitle = coder.decodeObjectForKey('subtitle')
    self.save = true
    return self
  end

  ##|
  ##|  DEBUG
  ##|
  def inspect append=nil
    "#{self.class.name}.new(name: #{self.name.inspect}, subtitle: #{self.subtitle.inspect}#{append ? ', ' + append : ''})"
  end


end
