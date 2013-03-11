
class Player
  class << self
    def plist
     'players.plist'.document
    end

    def persist
      self.players.writeToFile(plist, atomically:true)
    end

    def players
      @players || load_players
    end

    def <<(player)
      self.players << player
    end

    private
    def load_players
      if plist.exists?
        @players = Array.new(NSArray.alloc.initWithContentsOfFile(plist)) || []
      else
        @players = [
          {'name' => 'Mr. Pink'},
          {'name' => 'Mr. Blue'},
          {'name' => 'Mr. Orange'},
        ]
      end
      @players
    end

  end
end
